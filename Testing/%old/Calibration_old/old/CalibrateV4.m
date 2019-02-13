function out = Calibrate(inData, inOpts)
%Takes in normalized data and outputs the calibration values
%V2 : Optimize the optimization, remove old comments
%  b: Smooth instead of bin
%V3 : Remove junk
%  b:Since al=1 > diode response = 1 (bad), use one-term diode response

%Options and physical constants (can be overridden with inOpts)
opts.ra = 500; %Bead radius, nm
opts.Fmin = 50; %Fit start (Hz); end fit at Fnyq
opts.nBin = 1563; %Points per bin, currently taking 3127*200 pts, so closest divisor for 200 fit pts (half are tossed b/c Fnyq)
opts.Fs = 62500; %sampling freq.
opts.nAlias = 30; %Aliasing window size
opts.Fnyq = opts.Fs/2; %Nyquist freq.
opts.wV = 9.1e-10; %Water viscosity at 24C, pNs/nm^2
opts.kT = 4.10; %kB*T at 24C, pN*nm
opts.name = [];
opts.color = [.8 .8 .8];
opts.verbose = 1;
%Assign any overridden values
if exist('inOpts','var') && ~isempty(inOpts)
    fn = fieldnames(inOpts);
    for i = 1:length(fn)
        fname = fn{i};
        opts.(fname) = inOpts.(fname);
    end
end
%Create axis handle if not passed
if ~isfield(opts,'ax')
    opts.ax = gca;
end

%Calculate power spectrum
len = length(inData);
P = abs(fft(inData)).^2 / opts.Fs / (len-1);
F = (0:len-1)/(len-1)*opts.Fs;
%Chop constant term, so it won't be binned
F(1) = [];
P(1) = [];
len = len-1;

%Create bins
binF = (0:opts.nBin:len)+1;
%And bin the data
function outdata = binValues(data, binind)
    lenbin = length(binind)-1;
    outdata = zeros(1,lenbin);
    for ibin = 1:lenbin
        outdata(ibin) = mean(data(binind(ibin):binind(ibin+1)-1));
    end
end
Fb = binValues(F, binF);
Pb = binValues(P, binF);

%Keep indices within the fit frequency
ind = Fb>opts.Fmin & Fb<opts.Fnyq;
Fbf = Fb(ind);
Pbf = Pb(ind);

%Estimate Fc, D using a raw Lorentzian
[Fcg, Dg] = FitLorentzian(Fbf, Pbf);
Guess = [Fcg, Dg, .3, opts.Fnyq];

%Optimize in log-space
lPbf = log(Pbf);
fitfcn = @(x)(log(Lorentzian(x,Fbf,opts)) - lPbf);
options = optimoptions(@lsqnonlin);
options.Display = 'none';
fit = lsqnonlin(fitfcn, Guess,[],[],options);

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
    loglog(opts.ax, Fbf,Pbf,'o','Color',opts.color)
    hold on
    loglog(opts.ax, Fbf, (Lorentzian(fit,Fbf, opts)), 'Color', 'k', 'LineWidth',2)
    Pmin = min(Pbf);
    Pmax = max(Pbf);
    text(Fbf(1),(Pmin^2*Pmax)^.33,...
        sprintf(' %s \n \\itf_{c}\\rm: %0.0fHz \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.0fpN/NV',opts.name,fit(1),a,k,a*k),...
        'FontSize',12);
    opts.ax.XLim = [Fbf(1)*.9, Fbf(end)*1.1];
    opts.ax.YLim = [Pmin*.9, Pmax*1.1];
end

%Assemble output struct
out.fit = fit;
out.a = a;
out.k = k;
out.opts = opts;
out.F = Fbf;
out.P = Pbf;
end
