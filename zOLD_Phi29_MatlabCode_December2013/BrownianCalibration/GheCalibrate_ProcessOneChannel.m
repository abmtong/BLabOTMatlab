function Result = GheCalibrate_ProcessOneChannel(f,P,T,Def)
% P - power of the spectrum in this channel

    %% Unpackage the defined parameters, for convenience
    nBlock    = Def.nBlock;       % = 1500;  %number of spectrum data points in a block, we want ~50-200 binned points per fit
    nAlias    = Def.nAlias;       % = 20;    %use 20 aliasing terms
    nFitIter  = Def.nFitIter;     % = 50;    %max number of fit iterations 
    TolX      = Def.TolX;         % = 1e-7;  %tolerance in fit
    fSample   = Def.fSample;      % = 62500; %in Hz
    fNyq      = Def.fNyq;         % = round(fSample/2); %in Hz, has to be an integer
    iFitStart = Def.iFitStart;    % = 50;     %frequency range for initial fitting
    iFitEnd   = Def.iFitEnd;      % = 6000;   %in Hz
    fFitStart = Def.fFitStart;    % = 50;     %frequency range for final fitting
    fFitEnd   = Def.fFitEnd;      % = fNyq;   %in Hz

        
    %% Bin the Powerspectrum
    fb = GheCalibrate_MakeBlocks(f, nBlock);
    Pb = GheCalibrate_MakeBlocks(P, nBlock);
    s  = NaN*Pb; %preallocate memory, 's' is a weight for each Pb(i) point
    for i = 1:length(Pb)
        s(i) = (1/Pb(i))/sqrt(sum(isfinite(P((i-1)*nBlock+1 : i*nBlock)))); %this is basically a weight for the i-th block-point
    end

    %% Choose data to be fit by a simple Lorentzian in the first round
    ind     = (fb > iFitStart & fb <= iFitEnd);
    xfin    = fb(ind);
    yfin    = Pb(ind);
    %sfin    = s(ind); %not used anywhere

    % Guess FC (corner frequency) and D (diffusion coefficient)
    [fc0, D0, sfc, sD, Pfit] = GheCalibrate_LorentzAnalyt(xfin, yfin, T);

    % Taking into account aliasing using Nalias
    PAliasedNyq = sum((D0/(2*pi^2)) ./ ((fNyq + 2*(-nAlias:nAlias)*fNyq).^2 + fc0^2));

    % First guess for fDiode0 (3dB frequency of the photodiode)            
    if Pb(end) < PAliasedNyq
        dif      = Pb(length(Pb))/PAliasedNyq;
        fDiode0 = sqrt(dif*fNyq^2/(1 - dif));
    else
        fDiode0 = 2*fNyq;
    end

    % Alpha refers to the detector parasitic filtering correction
    Alpha0 = 0.3;
    A0 = sqrt(1/Alpha0^2 - 1);      % Substitute a0 for alpha to ensure that alpha lies between 0 and 1

    %% Define data to be fit with all corrections in the final fit
    ind  = (fb > fFitStart & fb <= fFitEnd);
    xfin = fb(ind);
    yfin = Pb(ind);
    sfin = s(ind);

    %% Final Fit
    Parameters0 = [fc0 D0 fDiode0 A0];             %Initial fitting parameters
    scal_fit = ones(1,length(Parameters0));         %Scaled fitting parameters

    fprintf('  Fitting final Lorenzian with corrections, ');
    [scal_fit, RESNORM, RESIDUAL, JACOBIAN] = ...
    GheCalibrate_FitNonlin(@GheCalibrate_Function, scal_fit, TolX, nFitIter, Parameters0, xfin, yfin, sfin);

    scal_fit   = abs(scal_fit);               % The function P_theor is symmetric in alpha and fdiode 
    Parameters = scal_fit.*Parameters0;
    Alpha      = 1/sqrt(1+Parameters(4)^2); %convert from A to Alpha
    nfree      = length(yfin) - length(Parameters);
    bbac       = 1. - gammainc(RESNORM/2.,nfree/2.);     %Calculate backing of fit
    chi2       = RESNORM/nfree;

    disp(['       ChiSq/DegOfFreedom = ',num2str(chi2,'%6.2f') '; Backing = ',num2str(bbac*100,'%3.0f') '%']);

    Parameters(4) = 1/sqrt(1+Parameters(4)^2); %make the reverse conversion to alpha
    for i= 1: length(Parameters0)-1
        JACOBIAN(:,i)=JACOBIAN(:,i)/Parameters0(i);     %Rescaling Jacobian back to unscaled parameters    
    end
    JACOBIAN(:,4) = JACOBIAN(:,4)/(-1/sqrt(1/Alpha0-1)*1/sqrt(1/Parameters(4)-1)*1/Parameters(4)^2);     %Rescaling Jacobian back to unscaled parameters    

    %% Errors on parameters
    CURVATURE = JACOBIAN' * JACOBIAN;
    cov       = GheCalibrate_Covariances(CURVATURE); %This way of inverting the CURVATURE matrix prevents a nearly singlular matrix in many cases
    sigma_par = GheCalibrate_SigmaPar(CURVATURE,Parameters);  
    
    %% Print a status update to command line
    line1 = [' fc = ' num2str(Parameters(1), '%5.0f') ' Hz'                 ' (+/-' num2str(sigma_par(1)/Parameters(1)*100, '%3.1f') '%)'];
    line2 = [' D  = ' num2str(Parameters(2), '%3.4f') ' NormVoltSquared/Hz' ' (+/-' num2str(sigma_par(2)/Parameters(2)*100, '%3.1f') '%)'];
    HorLine = [ line2 '---']; HorLine(:) = '-';
    %     %disp(['     ' HorLine ]);
    %     disp(['      ' line1    ]);
    %     disp(['      ' line2    ]);
    %     %disp(['     ' HorLine ]);
    fprintf('Raw fit values: %0.3f %0.3f %0.3f %0.3f\n', Parameters(1), Parameters(2), Parameters(3), Parameters(4));
     
    %% Compile Results
    Result.ScaledFit       = scal_fit;
    Result.Parameters0     = Parameters0;
    Result.Parameters      = Parameters;
    Result.ParametersSigma = sigma_par;
    Result.Covariance      = cov;
    Result.FitBacking      = bbac;
    Result.ChiSquared      = chi2;
    %Result.RawFrequency    = f; %before being Blocked
    %Result.RawPower        = P; %before being Blocked
    Result.BlockFrequency  = xfin; %x axis data to be fit
    Result.BlockPower      = yfin; %y axis data to be fit
    Result.FitFrequency    = xfin; %x axis data of the fit 
    Result.FitPower        = GheCalibrate_TheorP(scal_fit,Parameters0,xfin); %y axis data of the fit
    Result.fc              = Parameters(1);
    Result.fcSigma         = sigma_par(1);
    Result.D               = Parameters(2);
    Result.DSigma          = sigma_par(2);
    Result.f3dbDiode       = Parameters(3);
    Result.f3dbDiodeSigma  = sigma_par(3);
    Result.AlphaDiode      = Parameters(4);
    Result.AlphaDiodeSigma = sigma_par(4);

    % disp(['cov(fc,D)            = ',num2str(cov(1)/sqrt(Parameters(1)*Parameters(2)),'%8.3f')]);
    % disp(['cov(fc,fdiode)       = ' num2str(cov(2)/sqrt(Parameters(1)*Parameters(3)),'%8.3f')]);
    % disp(['cov(D,fdiode)        = ' num2str(cov(3)/sqrt(Parameters(2)*Parameters(3)),'%8.3f')]);
    % disp(['cov(fc,alpha)        = ' num2str(cov(4)/sqrt(Parameters(1)*Parameters(4)),'%8.3f')]); 
    % disp(['cov(D,alpha)         = ' num2str(cov(5)/sqrt(Parameters(2)*Parameters(4)),'%8.3f')]);
    % disp(['cov(fdiode,alpha)    = '
    % num2str(cov(6)/sqrt(Parameters(3)*Parameters(4)),'%8.3f')]);
end