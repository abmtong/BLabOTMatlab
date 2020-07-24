function parameters = Ghe_FitSpectrum(f,P,nblock,Lfit_start,Lfit_end,Ffit_start,Ffit_end,fSample)
% FIT_POWERSPECTRUM fits the powerspectrum data vs. frequency.
% The function fit_nonl is used.
% fNyq is the Nyquist frequency, fNyq = fSample/2
% TermTol - termination tolerance, try 1e-3 from the start
%
% adapted frum TweezerCalib2.1 by Ghe, 19 April 2011

%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
% Bin the powerspectrum
nbin    =   floor(length(f)/nblock);
fb = []; Pb = []; s = [];
for i = 1 : nbin,
    fb(i)   = mean_nan(f((i-1)*nblock+1 : i*nblock));
    Pb(i)   = mean_nan(P((i-1)*nblock+1 : i*nblock));
    s(i)    = (1/Pb(i))/sqrt(sum(isfinite(P((i-1)*nblock+1 : i*nblock))));
    %s is some sort of weight for each data point
end;
fb = fb(:); Pb = Pb(:); s = s(:);

%  Choose data used to guess Lorentzian parameters
ind     = find(fb > Lfit_start & fb <= Lfit_end);
xfin    = fb(ind);
yfin    = Pb(ind);
sfin    = s(ind);

% First guess for the fitting parameters FC (corner frequency) and D (diffusion coefficient)
[fc0,D0] = Ghe_GuessLorentzianParameters(xfin,yfin); 

% Guess the F3db for the diode parasitic filtering
f_diode0   =   fSample;

%  Choose data to be fit with the final fit
ind     = find(fb > Ffit_start & fb <= Ffit_end);
xfin    = fb(ind);
yfin    = Pb(ind);
sfin    = s(ind);

%%  Fit the Data using a custom minization, not quite least squares
check_flag =0;
alpha0 = 0.3; a0 = sqrt(1/alpha0^2 - 1);      % Substitute a0 for alpha to ensure that alpha lies between 0 and 1, this is done to avoid convergence problems during fitting

parameters0 = [fc0 D0 f_diode0 a0];    %Initial fitting parameters
scal_fit    = ones(size(parameters0)); %Scaled fitting parameters

MaxIter = 50; %maximum number of fitting iterations
TermTol = 1e-8; %termination tolerance

FittingFunction = @Ghe_FittingFunction;
[scal_fit,RESNORM, residual , J, X ] = Ghe_FitNonlinear(FittingFunction,scal_fit,TermTol,MaxIter,parameters0,xfin,yfin,sfin);
 
%[scal_fit,RESNORM,RESIDUAL,JACOBIAN] = Ghe_FitNonlinear(FittingFunction,scal_fit,TermTol,MaxIter,parameters0,xfin,yfin,sfin,check_flag);

% The function P_theor is symmetric in alpha and fdiode 
scal_fit   = abs(scal_fit);   
parameters = scal_fit.*parameters0;

disp(['Parameters: fc = ' num2str(parameters(1),'%5.1f') ...
      ', D = '            num2str(parameters(2),'%10.3e') ...
      ', fdiode = '       num2str(parameters(3),'%10.3e') ...
      ', alpha = '        num2str(parameters(4),'%5.3f')]);
disp(['chi^2 = ',num2str(RESNORM,'%6.2f')]);
nfree = length(yfin) - length(parameters0);
bbac = 1. - gammainc(RESNORM/2.,nfree/2.);     %Calculate backing of fit
chi2 = RESNORM/nfree;
disp(['chi^2 per degree of freedom = ',num2str(chi2,'%6.2f') ', n_{free} = ' num2str(nfree,'%6.2f')]);
disp(['backing = ',num2str(bbac,'%10.3e')]);