function out = CalibrateV3(inData, inOpts)
%Takes in normalized data and outputs the calibration values
%V2 : Optimize the optimization, remove old comments
%  b: Smooth instead of bin
%V3 : Remove junk
%  b:Since al=1 > diode response = 1, maybe do one-term Lorentzian, or lb/ub

%Options and physical constants (can be overridden with inOpts)
opts.ra = 500; %Bead radius, nm
opts.Fmin = 50; %Fit start (Hz); end fit at Fnyq
opts.nBin = 1563; %Points per bin, currently taking 3127*200 pts, so closest divisor for 200 fit pts (half are tossed b/c Fnyq)
opts.Fs = 62500; %sampling freq.
opts.nAlias = 20; %Aliasing window size
opts.Fnyq = opts.Fs/2; %Nyquist freq.
opts.wV = 9.1e-10; %Water viscosity at 24C, pNs/nm^2
opts.kT = 4.10; %kB*T at 24C, pN*nm
%Assign any overridden values
if nargin > 1
    fn = fieldnames(inOpts);
    for i = 1:length(fn)
        fname = fn{i};
        opts.(fname) = inOpts.(fname);
    end
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
Fb = binValues(F, binF);
Pb = binValues(P, binF);

%Keep indices within the fit frequency
ind = Fb>opts.Fmin & Fb<opts.Fnyq;
Fbf = Fb(ind);
Pbf = Pb(ind);

%Guess parameters
%        fc  D  al f3
Guess = [5e3 .3 .4 2e4]; 
%Guess = [1e4 .3 .1 6e4]; 

%Optimize the difference of the squares of the logs
lPbf = log(Pbf);
fitfcn = @(x)(log(Lorentzian(x,Fbf,opts)) - lPbf);
options = optimoptions(@lsqnonlin);
options.Display = 'none';
out = lsqnonlin(fitfcn, Guess,[],[],options);

%Plot - move to something else later
figure
loglog(Fbf,Pbf,'o')
hold on
loglog(Fbf, (Lorentzian(out,Fbf, opts)))
fprintf('Guess: %0.2f %0.2f %0.2f %0.2f \n  Fit: %0.2f %0.2f %0.2f %0.2f\n',Guess(1),Guess(2),Guess(3),Guess(4),out(1),out(2),out(3),out(4))

%Calculate alpha, kappa from fit parameters
%Drag coefficient of a sphere in water
dC = 6*pi*opts.wV*opts.ra;
%Theoretical D
D = opts.kT/dC;
%Conversion factor alpha
a = sqrt(D/out(2));
%Spring constant kappa
k = 2*pi*dC*out(1);

fprintf('Bead params %0.3f %0.3f %0.3f\n', k, a, a*k)

function outdata = binValues(data, binind)
len = length(binind)-1;
outdata = zeros(1,len);
for i = 1:len
    outdata(i) = mean(data(binind(i):binind(i+1)-1));
end