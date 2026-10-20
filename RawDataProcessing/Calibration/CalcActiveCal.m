function out = CalcActiveCal(infp, inOpts)


%input: dat = loadfile_wrapper()
%       opts = DataOptsPopup

opts.foo = 'bar';


if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.dat');
    infp = fullfile(p,f);
end

if nargin >=2
    opts = handleOpts(opts, inOpts);
else
    opts = DataOptsPopup;
end

if isfield(opts, 'cal')
    opts = handleOpts(opts, opts.cal); %Eh just add opts.cal to opts and 'itll be fine'
end

dat = loadfile_wrapper(infp, opts);

if dat.meta.hdr(end-3) %Flag for active calibration (Avogadro)
    npts = dat.meta.hdr(end-2);
else
%     npts = 2000; %Just take default. Or error?
    resp = inputdlg({'Number of points for active cal not found, how many?'}, 'Active Cal Options', 1, {' 2000 '});
    npts = str2double(resp);
end
Fs = 1/dat.meta.Fsamp; %'Fsamp' field is actually 1/Fsamp
drvfreq = Fs/npts; 


%Send to normal Calibrate. Make sure fmin > fdrive.. lets say 1.5x or so
if isfield(opts, 'Fmin')
    opts.Fmin = max( opts.Fmin, drvfreq*1.5 );
else
    opts.Fmin = drvfreq * 1.5;
end

%Calibrate with ACalibrate. Assume npts is okay (total data length = N * npts)
acal = ACalibrateV2(infp, opts);

%Take power spec, power at driving freq equals:
% power (spike) - power (background lorentzian) = A^2 / 2( 1 + fc^2/fdrive^2) * dt
%  to equalize units, P(V) * alpha^2 = A^2 / (...) , this gives you alpha -> update kappa
% Dnm = opts.kT/dC;, a^2 =  Dnm/Dv, k = 2*pi*dC*Fc;
%  Rearranging, a^2 = kT/dC/Dv -> dC = kT/a2/Dv ; k = 2pi dC Fc = 2pi kT Fc / a^2 / Dv
% Need to get a single pt. at 50Hz (pad/trim pspec)? or will be the 'integral' anyway? (check)
%  Sometimes this spike happens over two freqs, eg 468k pts has it at 1pt but 467k has it over a few pts
%   Probably needs to be a multiple of driving freq

%Hmm need to edit Calibrate code to trim force first, then bin, else the driving freq is added... ok to do?

%Get power spike = max of Fax (probably good? Or take nearest to drive freq?)
fns = {'AX', 'BX'}; %Calculate off of these acal.(fns{i}) fields
fnsr = {'raA' 'raB'};
len = length(fns);
rr = nan(1,len); %Store new radii
for i = 1:len
    %Get closest pt to driving freq
    [~, ifreq] = min( abs( acal.(fns{i}).Fall - drvfreq ) );
    %Calculate Lorentzian power
    Pfit = Lorentzian(acal.(fns{i}).fit, acal.(fns{i}).Fall(ifreq), acal.(fns{i}).opts);
    %Subtract measured minus background Lorentzian
    pdrv = acal.(fns{i}).Pall(ifreq) - Pfit; %Subtract background Lorentzian, probably minimal but eh do anyway
    Adrv = dat.meta.hdr(end-1) * opts.convTrapX; %Driving amplitude, nm
    
    fudge = 1; %Larger by some amount, fudge
    al = Adrv * sqrt( length(dat.(fns{i})) /Fs / 2 / pdrv / (1+ (acal.(fns{i}).fit(1) / drvfreq )^2 ) ) * fudge;
    %Calculate new radius from alpha: dC = kT/a^2/Dv = 6pi eta r
    rnew = acal.(fns{i}).opts.kT / al^2 / acal.(fns{i}).fit(2) / 6 / pi / acal.(fns{i}).opts.wV;
    
    
    al = Adrv / sqrt(  2 * pdrv * (1+ (acal.(fns{i}).fit(1) / drvfreq )^2 ) * Fs/length(dat.(fns{i})) ) ;
    % They write 'delta f' : what is this? the frequency resolution? yes, = Fsamp/Npts
    %  Number is pretty good if you omit the Fs/length() term, but obvs cant (just a coincidence)
    %  Corrected alpha is 2x regular alpha, probably too much (== bead size 4x too large)
    
    %And new params from radius
    
    dC = 6*pi * acal.(fns{i}).opts.wV * rnew;
    %Theoretical Diffusion Coefficient
    D = acal.(fns{i}).opts.kT/dC;
    %Conversion factor alpha, gotten by the ratio of D (nm^2/V^2)
    alnew = sqrt(D/acal.(fns{i}).fit(2));
    
    %Spring constant kappa, 2 pi dC Fc
    knew = 2*pi*dC*acal.(fns{i}).fit(1);
    
    %Update fields
    rr(i) = rnew;
    acal.(fnsr{i}) = rnew; %Save radius in opts field... will have to go looking for it
    acal.(fns{i}).al = alnew;
    acal.(fns{i}).k = knew;

end




out = acal;
% 
% 
% return

fns = {'AX', 'BX'}; %Calculate off of these acal.(fns{i}) fields
fnsy = {'AY' 'BY'};
fnssum = {'AS', 'BS'};
fnst = {'T1F' 'T2F'};
fnsr = {'raA' 'raB'};
len = length(fns);
rr = nan(1,len); %Store new radii
for i = 1:len
    
    %Calculate active calibration with driven damped SHM method
    
    
    %For a sin-driven damped SHO:
    % Damping factor b  == dC/2m =  6pi eta r / 2m
    % Harmonic frequency w0^2 == k/m
    % Mass m = 4/3 pi r^3 rho_polystyrene [or whatever bead]
    % Driving term f0 sin(wt), f0 == amplitude of AX * al * k
    % Driving freq w
    % tan(phase delay) = 2 b w / ( w0^2 - w^2 )
    % Particle motion A sin(wt), A^2 = f
    %So can measure the normal powspec D and Fc, fit sin to data to get AX = AX0 sin(wt) and ext = EX0 sin(wt - delta)
    % Then calculate r to make the equations equal? And hope it is ~500nm? lsqnonlin it?
    
    
    %Average by sin period, which should be dat.meta.hdr(end-3)
    if dat.meta.hdr(end-3) %Flag for active calibration (Avogadro)
        npts = dat.meta.hdr(end-2);
    else
        npts = 2000; %Just take the current default if hdr is wrong. Or
    end
    
    %Average spectra. Crop if unequal to npts
    xx = mean( reshape( dat.(fns{i})( 1: floor(end/npts)*npts) ./ dat.(fnssum{i})( 1: floor(end/npts)*npts), npts, []), 2);
    tt = mean( reshape( dat.(fnst{i})( 1: floor(end/npts)*npts), npts, []), 2) * opts.convTrapX;
    %Zero mean for fitting to sin(x), negate force ...?
    xmn = double(-(xx-mean(xx)))' ;
    tmn = double(( tt-mean(tt) ))' ;
    
    %Calculate phase delay
    fitfcn = @(x0,x) x0(1) * cos(x * 2*pi/npts - x0(2));
    %Generate guess = find max pt, use this as amplitude and delay
    [ftxg(1), ftxg(2)] = max(xmn);
    [fttg(1), fttg(2)] = max(tmn);
    ftxg(2) = ftxg(2) / npts * 2 * pi;
    fttg(2) = fttg(2) / npts * 2 * pi; %fttg should be = ftt [no noise], but fit anyway
    %Fit
    ftx = lsqcurvefit(fitfcn, [max(xmn) 0], 1:npts, xmn, [0 -inf], [inf inf]);
    ftt = lsqcurvefit(fitfcn, [max(tmn) 0], 1:npts, tmn, [0 -inf], [inf inf]);
    
    thdelay = mod( ftt(2)-ftx(2), 2*pi); %Make sure this is the right sign? Just take abs(tan(delta)) ?
    % BX was lower in magnitude and higher in delay = more drag? Would more drag would decrease max(BX), as is observed ?
    
    Adrv = dat.meta.hdr(end-1) * opts.convTrapX* 1e-9; %nm -> m
    
    %Constants/fits
    w = drvfreq * 2 * pi; %rev/s -> rad/s... theory has f = f0 cos(wt) so w should be rad/s
    rhops = 1.05; %Polystyrene density, g/cm3, number from BangsLabs
    Dfit = acal.(fns{i}).fit(2); %D, NV^2/s unit
    fcfit = acal.(fns{i}).fit(1); %Fc, Hz
    kT = acal.(fns{i}).opts.kT * 1e-12 * 1e-9; %kT, pNnm -> Nm
    
    %Primary r-based terms. Convert to SI units, so kill pN and nm etc.
    mr = @(r) 4/3 * pi * (r*1e-7)^3 * rhops / 1e3 ; %mass, kg; input radius is nm [convert to cm first, multiply by rho to g, then to kg]
    dCr = @(r) 6*pi*acal.(fns{i}).opts.wV* r * 1e-12 / 1e-9 / 1e-9 * 1e-9 ; %Viscosity is pNs/nm^2 , r is nm, output in SI kg/s
    Dr = @(r) kT / dCr(r); %SI

    %Derived r-based terms
    alr = @(r) sqrt( Dr(r) / Dfit ); %This alpha is m/NV, not nm/NV like normal
    kr = @(r) 2*pi*dCr(r)*fcfit; %N/m
    br = @(r) dCr(r)/mr(r)/2; %Ns/m2
    f0r = @(r) ftx(1) * alr(r) * kr(r) / mr(r); %F/m = AX*al*ka/m
    
%     rr =500;
    %A^2 = f0^2 /[ (w0^2-w^2)^2 + 4b^2w^2 ] and tan(delta) = 2bw / (w0^2-w^2)
    % Rearrange to remove w0^2-w^2: A^2 = f0^2 / ( 4 b^2 w^2 (1+cot(delta)) )
    % So A = f0 / (2bw sqrt(1+cot(delta) ) );
%     A2 = ftx(1) * alr(rr) * kr(rr) / ( 2 * br(rr) * w * sqrt(1 + abs(cot(thdelay))) ) / mr(rr);
    
    %This calc seems off by almost exactly 4... maybe some factors of 2 off or something? freq in rev/s vs rad/s ?
    fudge = 1; %Fudge factor for A calc. Factors of 2 somewhere?
    Ar = @(r) f0r(r) / ( 2 * br(r) * w * sqrt(1 + cot(thdelay)^2 ) )* fudge ;
    
    %Do lsqnonlin, normalize by Adrv so function tolerance is ok
    % Update A (response amplitude) to be roughly Adrv - AX*alpha [assumes delta == 0, but it is close to zero]
    rr = lsqnonlin(@(x0) (Ar(x0) - (ftt(1)*1e-9 - ftx(1) * alr(x0) ) )/Adrv, acal.(fns{i}).opts.ra, 0 , inf); 
%     rr2 = lsqnonlin(@(x0) (Ar(x0) - (ftt(1)*1e-9 ) )/A, acal.(fns{i}).opts.ra, 0 , inf);% Could do this without updating A
    
%     %For curiosity, what is w0? doesn't seem meaningful, I would guess it should be like Fc ish?
%     %2bw/tan delta = w02 - w2
%     w0 = sqrt( 2 * br(rr) * w / tan(thdelay) + w^2 ); %For this data, w0 = 26kHz... thats Fc ish


    %Update cal
    acal.(fnsr{i}) = rr; %'Readable' opts.rA
    acal.(fns{i}).opts.ra = rr; %Used by @plotcal
    acal.(fnsy{i}).opts.ra = rr; %Used by @plotcal
    
    acal.(fns{i}).k = kr(rr) * 1e3; %Remember these are SI, so convert to pN & nm
    acal.(fns{i}).a = alr(rr)* 1e9;
    
    acal.(fnsy{i}).a = sqrt( Dr(rr) / acal.(fnsy{i}).fit(2) ) * 1e9 ;
    acal.(fnsy{i}).k = 2*pi*dCr(rr)*acal.(fnsy{i}).fit(1) * 1e3;
    
end

plotcal(acal)
out = acal;






