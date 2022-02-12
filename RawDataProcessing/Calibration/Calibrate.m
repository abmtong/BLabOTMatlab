function out = Calibrate(inData, inOpts)
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
opts.dV = 1.25e-9; %D2O viscosity at 20C, pNs/nm^2
opts.d2o = 0; %Proportion D2O, =0 = all H2O, =1 = all D2O
opts.kT = 4.10; %kB*T at 24C, pN*nm
opts.name = []; %Name of this detector, e.g. 'AX'
opts.color = [0 0 1]; %Color to plot the power spectrum fit points
opts.verbose = 1;
opts.Sum = 0;
opts.lortype = 3; %1 = pure lorentzian, 2 = 1 filter, 3 = filter+timedelay, 4 = 2 filters

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Special opts handling
opts.Fnyq = opts.Fs/2; %Nyquist freq, used in Fmax or opts. guess
if isempty(opts.Fmax)
    opts.Fmax = opts.Fs/2; %Nyquist freq.
end

%Calculate viscosity using Arrhenius' rule
opts.wV = exp( log(opts.wV) * (1-opts.d2o) + log(opts.dV) * (opts.d2o) );

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

% Fb = geofilter(F, 1.05);
% Pb = geofilter(P, 1.05);

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

%Estimate Fc, D using a Lorentzian without the instrument's 'filter'
[Fcg, Dg] = FitLorentzian(Fbf, Pbf);
% Guess = [Fcg, Dg, 1, 0];

%Assign lb and ub

switch opts.lortype
    case 3 %time delay
        lb = [0 0 0 0];
        ub = [10*Fcg 10*Dg 1 opts.Fs*10];
%         Guess = [Fcg, Dg, .3, opts.Fnyq/2];
        Guess = [Fcg, Dg, .3, 1e4];
    case 5 %Fc D al f0 g0 f1 g1
        lb = [0 0 0 0 0 0 0];
        ub = [10*Fcg, 10*Dg, 1 inf inf inf inf];
        Guess = [Fcg, Dg, .3, opts.Fnyq/2, .5, opts.Fnyq/3, .5 ];
    otherwise %just first order filters
        lb = [0 0 0 25000];
        ub = [10*Fcg 10*Dg opts.Fs*10 opts.Fs*10];
        Guess = [Fcg, Dg, .3, opts.Fnyq/2];
end

%Optimize in log-space
lPbf = log(Pbf);
fitfcn = @(x)(log(Lorentzian(x,Fbf,opts)) - lPbf);
options = optimoptions(@lsqnonlin);
options.Display = 'none';
fit = lsqnonlin(fitfcn, Guess,lb,ub,options);
%tweezercalib essentially does >>fit = lsqcurvefit(@(x,f)Pbf./Lorentzian(x,f,opts),Guess,Fbf,ones(1,length(Fbf)),[],[],options);
% There is no real difference between the two, +-1% difference. I like normalizing in log-space over normalizing all values to 1.
% @lsqcurvefit(@(x,xdata)fcn(x,xdata), xdata, ydata,...) is essentially @lsqnonlin(@(x)fcn(x,xdata)-ydata,...), doesn't matter which to use

%Calculate alpha, kappa from fit parameters
%Drag coefficient of a sphere in water (unit 
dC = 6*pi*opts.wV*opts.ra;
%Theoretical Diffusion Coefficient
D = opts.kT/dC;
%Conversion factor alpha, gotten by the ratio of D (nm^2/V^2)
a = sqrt(D/fit(2));
%Spring constant kappa, 2 pi dC Fc
k = 2*pi*dC*fit(1);

%Plot fit, display values
if opts.verbose
    loglog(opts.ax, Fall, Pall, 'Color', .8*[1 1 1])
    hold on
    loglog(opts.ax, Fbf,Pbf,'o','Color',opts.color)
    loglog(opts.ax, [Fall(1) Fbf Fall(end)], (Lorentzian(fit,[Fall(1) Fbf Fall(end)], opts)), 'Color', 'k', 'LineWidth',2)
    Pmin = min(Pbf);
    Pmax = max(Pbf);
    text(opts.Fmin,(Pmin^2*Pmax)^.33,...
        sprintf(' %s \n fc: %0.0fHz \n D: %0.3f\n al: %0.3f\n f3: %0.1f \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV \n r: %dnm Sum: %0.2fV wV: %0.2e \n ',opts.name,fit,a,k,a*k, opts.ra, opts.Sum, opts.wV),...
        'FontSize',12);
%         sprintf(' %s \n \\itf_{c}\\rm: %0.0fHz \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV',opts.name,fit(1),a,k,a*k),...
%         'FontSize',12);
%     opts.ax.XLim = [Fbf(1)*.9, Fbf(end)*1.1];
    opts.ax.XLim = [opts.Fmin*.09, opts.Fmax*1.1];
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