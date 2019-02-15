%Based on CalibrateV4, merged into one script for use as MathScript
%Inputs: Bead radius, name
ra = 500;
name = 'AX';

%Options and physical constants (can be overridden with inOpts)

Fmin = 50; %Fit start (Hz); end fit at Fnyq
nBin = 1563; %Points per bin, currently taking 3127*200 pts, so closest divisor for 200 fit pts (half are tossed b/c Fnyq)
Fs = 62500; %sampling freq.
nAlias = 20; %Aliasing window size
Fnyq = Fs/2; %Nyquist freq.
wV = 9.1e-10; %Water viscosity at 24C, pNs/nm^2
kT = 4.10; %kB*T at 24C, pN*nm
color = [.8 .8 .8];
verbose = 1;
figure
ax = gca;

%Calculate power spectrum
len = length(inData);
P = abs(fft(inData)).^2 / Fs / (len-1);
F = (0:len-1)/(len-1)*Fs;
%Chop constant term, so it won't be binned
F(1) = [];
P(1) = [];
len = len-1;

%Create bins
binF = (0:nBin:len)+1;
%And bin the data
lenbin = length(binF)-1;
Fb = zeros(1,lenbin);
Pb = zeros(1,lenbin);
for ibin = 1:lenbin
    Fb(ibin) = mean(F(binF(ibin):binF(ibin+1)-1));
    Pb(ibin) = mean(P(binF(ibin):binF(ibin+1)-1));
end

%Keep indices within the fit frequency
ind = Fb>Fmin & Fb<Fnyq;
Fbf = Fb(ind);
Pbf = Pb(ind);

%Estimate Fc, D using a raw Lorentzian
for i = 0:2
    for j = 0:2
        c.(sprintf('s%d%d',i,j)) = sum( (Fbf.^(2*i)) .* (Pbf.^j) );
    end
end
a   = (c.s01 * c.s22 - c.s11 * c.s12) / (c.s02 * c.s22 - c.s12.^2);
b   = (c.s11 * c.s02 - c.s01 * c.s12) / (c.s02 * c.s22 - c.s12.^2);
Fcg  = sqrt(a/b);
Dg   = (1/b) * 2 * (pi.^2);

Guess = [Fcg, Dg, .3, Fnyq];

%Create the Lorentzian fcn
inFF = bsxfun(@plus, Fbf, Fs*(-nAlias:nAlias)');
Lorentzian = @(x, Fbf) (sum( x(2)/2/pi^2./(x(1)^2+inFF.^2) .* (x(3)^2 + (1-x(3)^2) ./ (1+ (inFF/x(4)).^2)) ));

%Optimize in log-space
lPbf = log(Pbf);
fitfcn = @(x)(log(Lorentzian(x,Fbf)) - lPbf);
options = optimoptions(@lsqnonlin);
options.Display = 'none';
fit = lsqnonlin(fitfcn, Guess,[],[],options);

%Calculate alpha, kappa from fit parameters
%Drag coefficient of a sphere in water
dC = 6*pi*wV*ra;
%Theoretical D
D = kT/dC;
%Conversion factor alpha
a = sqrt(D/fit(2));
%Spring constant kappa
k = 2*pi*dC*fit(1);

%Plot fit, display values
if verbose
    loglog(ax, Fbf,Pbf,'o','Color',color)
    hold on
    loglog(ax, Fbf, (Lorentzian(fit,Fbf, opts)), 'Color', 'k', 'LineWidth',2)
    Pmin = min(Pbf);
    Pmax = max(Pbf);
    text(Fbf(1),(Pmin^2*Pmax)^.33,...
        sprintf(' %s \n \\itf_{c}\\rm: %0.0fHz \n \\alpha: %0.0fnm/NV \n \\kappa: %0.3fpN/nm \n \\alpha*\\kappa: %0.1fpN/NV',name,fit(1),a,k,a*k),...
        'FontSize',12);
    ax.XLim = [Fbf(1)*.9, Fbf(end)*1.1];
    ax.YLim = [Pmin*.9, Pmax*1.1];
end

%Outputs
a;
k;