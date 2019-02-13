function out = tscalibrate(inData, inOpts)
%Takes in normalized data and outputs the calibration values as a structure
%Output fields:
    %fit: Lorentzian fit parameters, = [Fc D al F3]
    %a: Trap conversion factor alpha(nm/NV)
    %k: Spring constant kappa (pN/nm)
    %opts: Options struct
    %F: Fit frequency
    %P: Fit power
    %dC: Theoretical drag coefficient
    %D: Theoretical D
%Important Options fields:
    %ra: Bead radius (nm)
    %--Graph options
    %verbose: Whether to graph
    %ax: Axis handle to graph location
    %name: Name to put in graph

%Options and physical constants (can be overridden with inOpts)
opts.ra = 500; %Bead radius, nm
opts.Fmin = 100; %Fit start (Hz); end fit at Fnyq unless overridden
opts.Fmax = [];
opts.nBin = 1563; %Points per bin, currently taking 3127*200 pts, so closest divisor for 200 fit pts (half are tossed b/c Fnyq)
opts.Fs = 62500; %sampling freq.
opts.nAlias = 20; %Aliasing window size
opts.wV = 9.1e-10; %Water viscosity at 24C, pNs/nm^2
% opts.wV = 1.25e-9; %D2O viscosity at 20C, pNs/nm^2
opts.kT = 4.10; %kB*T at 24C, pN*nm
opts.name = []; %Name of this detector, e.g. 'AX'
opts.color = [.8 .8 .8]; %Color to plot power spectrum
opts.verbose = 1;
opts.Sum = 0;
opts.hydro = 0;
%Assign any overridden values
if exist('inOpts','var') && isstruct(inOpts)
    fn = fieldnames(inOpts);
    for i = 1:length(fn)
        fname = fn{i};
        opts.(fname) = inOpts.(fname);
    end
end
%Special opts handling
opts.Fnyq = opts.Fs/2; %Nyquist freq, used in Fmax or opts. guess
if isempty(opts.Fmax)
    opts.Fmax = opts.Fs/2; %Nyquist freq.
end

%Create axis handle if not passed
if ~isfield(opts,'ax') && opts.verbose
    opts.ax = gca;
end

%Make inData a row vector
inData = reshape(inData, 1, []);

%Calculate power spectrum
len = length(inData);
P = abs(fft(inData)).^2 / opts.Fs / (len-1);
F = (0:len-1)/(len-1)*opts.Fs;
%Chop constant term, so it won't be binned
F(1) = [];
P(1) = [];
len = len-1; %Could assign len=len-1 earlier, but more clarity here (aligns with usual powerspec calculations, keeps my convention of len)

%Create bins
binF = (0:opts.nBin:len-1)+1;
%And bin the data
    function outdata = binValues(data)
        lenbin = length(binF)-1;
        outdata = zeros(1,lenbin);
        for ibin = 1:lenbin
            outdata(ibin) = mean(data(binF(ibin):binF(ibin+1)-1));
        end
    end
Fb = binValues(F);
Pb = binValues(P);

%Keep indices within the fit frequency
ind = Fb>opts.Fmin & Fb<opts.Fmax;
Fbf = Fb(ind);
Pbf = Pb(ind);

%Filter for plotting the whole, filters down to splitnum * (len/2) ^ (1/splitnum) points
splitnum = 5;
filtfact = 5;
binfacts = filtfact .^(0:splitnum-1);
Phalf = P(1:round(end/2));
Fhalf = F(1:round(end/2));
len2 = length(Phalf);
Pall = cell(1, splitnum);
Fall = cell(1, splitnum);
%divide Pf into exponentially equivalent length
inds = round(len2 .^ ((0:splitnum )/ splitnum));
%filter
for i = 1:splitnum
    Pall{i} = windowFilter(@mean, Phalf(inds(i):inds(i+1)), [], binfacts(min(i, length(binfacts))));
    Fall{i} = windowFilter(@mean, Fhalf(inds(i):inds(i+1)), [], binfacts(min(i, length(binfacts))));
end
%join
Pall = [Pall{:}]';
Fall = [Fall{:}]';

%Estimate Fc, D
[Fcg, Dg] = tscalibrate_lorentzguess(Fbf, Pbf);

%Set up hydro or non-hydro espectrum
if opts.hydro
    n = 9e-10; % [pN s/nm^2] water viscosity at 24.4C
    p = 1e-21; % [pN s^2/nm^4] water density
    pbead = 1.05e-21; % [pN s^2/nm^4] bead density polystyrene
    % pbead = 2e-21; % [pN s^2/nm^4] bead density silica particles, mau
    % pbead = 19.3e-21; % [pN s^2/nm^4] bead density gold, troy
    beadA = opts.ra;
    gA = 3*pi*n*beadA;
    mA = pi/6*pbead*beadA^3;
    % Set Hydrodynamic Parameters
    fmA = gA/(2*pi*(mA+pi/12*p*beadA^3));
    fvA = n/p/(pi*beadA^2/4);
    lzian = @(x, f, ops)tscalibrate_lorentzian_hydro([x fmA fvA], f, ops) ;
    Guess = [Fcg, Dg];
else
    lzian = @tscalibrate_lorentzian;
    Guess = [Fcg, Dg];
end

lb = zeros(1, length(Guess));
ub = inf(1, length(Guess));

%Optimize in log-space
lPbf = log(Pbf);
fitfcn = @(x)(log(lzian(x,Fbf,opts)) - lPbf);
options = optimoptions(@lsqnonlin);
options.Display = 'none';
fit = lsqnonlin(fitfcn, Guess, lb, ub, options);
%tweezercalib essentially does >>fit = lsqcurvefit(@(x,f)Pbf./Lorentzian(x,f,opts),Guess,Fbf,ones(1,length(Fbf)),[],[],options);
% There is no real difference between the two, +-1% difference. I like normalizing in log-space over normalizing all values to 1.
% @lsqcurvefit(@(x,xdata)fcn(x,xdata), xdata, ydata,...) is essentially @lsqnonlin(@(x)fcn(x,xdata)-ydata,...), doesn't matter which to use

%Calculate alpha, kappa from fit parameters
%Drag coefficient of a sphere in water
dC = 6*pi*opts.wV*opts.ra;
%Theoretical D
D = opts.kT/dC;
%Conversion factor alpha
a = sqrt(D/fit(2));
%Spring constant kappa
k = 2*pi*dC*fit(1);

%Plot fit, display values
if opts.verbose
    %@smooth causes an artefact for spectra with very high F(1), manifesting as a jump at F(filterwidth/2)
    %@smooth is slow for bad computers, so maybe replace
    
    loglog(opts.ax, Fall, Pall, 'Color', .8*[1 1 1])
    hold on
    loglog(opts.ax, Fbf,Pbf,'o','Color',opts.color)
    loglog(opts.ax, Fbf, (lzian(fit, Fbf, opts)), 'Color', 'k', 'LineWidth',2)
    Pmin = min(Pbf);
    Pmax = max(Pbf);
    text(Fbf(1),(Pmin^2*Pmax)^.33,...
        sprintf(' %s \n fc: %0.0fHz \n D: %0.3f\n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV \n r: %dnm Sum: %0.2fV \n ',opts.name,fit(1),fit(2),a,k,a*k, opts.ra, opts.Sum),...
        'FontSize',12);
%         sprintf(' %s \n \\itf_{c}\\rm: %0.0fHz \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV',opts.name,fit(1),a,k,a*k),...
%         'FontSize',12);
    opts.ax.XLim = [Fbf(1)*.9, Fbf(end)*1.1];
    opts.ax.YLim = [Pmin*.9, Pmax*1.1];
end

%Assemble output struct
out.fit = fit;
out.a = a;
out.k = k;
out.opts = opts;
out.F = Fbf;
out.Fall = Fall;
out.P = Pbf;
out.Pall = Pall;
out.dC = dC;
out.D = D;
end