function out = CalibrateV2b(inData, inOpts)
%Takes in normalized data and outputs the calibration values
%V2 : Optimize the optimization, remove old comments
%  b: Smooth instead of bin

inData = double(inData);

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

% %Calculate guesses for each fit parameter (probably unnecessary)
% %Estimate Fc, D using a raw Lorentzian
% [Fcg, Dg] = FitLorentzian(Fbf, Pbf);
% %Aliasing, to estimate f3
% Palias = sum((Dg/(2*pi^2)) ./ ((Fnyq + 2*(-nAlias:nAlias)*Fnyq).^2 + Fcg^2));
% % First guess for fDiode0 (3dB frequency of the photodiode)
% if Pb(end) < Palias
%     dif      = Pb(end)/Palias;
%     f3g = sqrt(dif*Fnyq^2/(1 - dif));
% else
%     f3g = Fs;
% end

%        fc  D   al f3
%Guess = [Fcg, Dg, .3, f3g];
Guess = [5000 .300 .4 2e4]; 

% %S is a fitting weight - higher S, the more important to fit (Skew for lower power regions - the high freq ones)
% S = 1./Pb/sqrt(opts.nBin);
% Sf = S(ind);
%fitfcn = @(x)(Lorentzian(x,Fbf,opts) - Pbf) .* Sf;
%fitfcn = @(x)(1./Lorentzian(x,Fbf,opts) - 1./Pbf) .* 1./Sf;

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
out(3) = (out(3)^2+1)^-.5;
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