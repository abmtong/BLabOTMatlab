function out = Calibrate(inData)
%Takes in normalized data and outputs the calibration values

ra = 500; %Bead radius, nm
Fmin = 50; %Fit start, Hz; end fit at Fnyq
nb = 1562; %Points per bin, currently taking 3127*200 pts, so closest divisor for 200 fit pts (half are tossed b/c Fnyq)

Fs = 62500; %sampling freq.
wV = 9.1e-10; %Water viscosity at 24C, pNs/nm^2
kT = 4.10; %kB*T at 24C, pN*nm
len = length(inData);
P = abs(fft(inData)).^2 / Fs / (len-1);
F = (0:len-1)/(len-1)*Fs;


% %Works best with even-numbered len.
% if rem(len, 2) ~= 0
%     inData = inData(1:end-1);
%     len = len - 1;
% end
% %Take FFT, cutoff at fNyq
% dft = fft(inData);
% dft = dft(1:len/2+1);
% %Calculate power from FFT
% P = abs(dft).^2 /Fs /len;
% %Double the middle values to "conserve power" - see >>doc fft
% P(2:end-1) = 2*P(2:end-1);
% %Freq runs from 0 to FNyq
% F = (0:len/2)*Fs/len;

%Create bins
binF = (0:nb:len)+1;
%And bin the data
Fb = binValues(F, binF);
Pb = binValues(P, binF);
%Constant term doesn't behave, chop it off
Fb = Fb(2:end);
Pb = Pb(2:end);



nAlias = 20;
Fnyq = Fs/2;
% 
% %Aliasing to guess F3
% PAlias = sum((Dg/(2*pi^2)) ./ ((fNyq + 2*(-nAlias:nAlias)*fNyq).^2 + Fcg^2));
% % First guess for fDiode0 (3dB frequency of the photodiode)
% if Pb(end) < PAlias
%     dif = Pb(end)/PAlias;
%     F3g = sqrt(fNyq^2/(1/dif - 1));
% else
%     F3g = Fs;
% end



ind = Fb>Fmin & Fb < Fnyq;
Fbf = Fb(ind);
Pbf = Pb(ind);

%Basic fit, to estimate Fc, D
[Fcg, Dg] = FitLorentzian(Fbf, Pbf);

%Aliasing, to estimate f3
Palias = sum((Dg/(2*pi^2)) ./ ((Fnyq + 2*(-nAlias:nAlias)*Fnyq).^2 + Fcg^2));

% First guess for fDiode0 (3dB frequency of the photodiode)
if Pb(end) < Palias
    dif      = Pb(end)/Palias;
    f3g = sqrt(dif*Fnyq^2/(1 - dif));
else
    f3g = Fs;
end

%        fc  D   A f3
%alpha optimized as A=sqrt(1/alpha^2-1), so alpha = (A^2+1)^-.5 , guess 0.3
%Guess = [Fcg Dg  3.2  f3g];
Guess = [5000 .300 .4 2e4]; 
% ub    = [1e5 1e2  1e2  1e6];
% lb    = [1e3 1e-2 1e-2 1e3];

% options = optimoptions(@lsqcurvefit);
% options.OptimalityTolerance = 1e-30;
% options.FunctionTolerance = 1e-50;
% options.StepTolerance = 1e-50;
% options.MaxFunctionEvaluations = 1e5;
% options.MaxIterations = 1e5;
% options.Display = 'none';

%Start New Stuff
%S is a fitting weight - higher S, the more important to fit
S = zeros(1,length(Pb));
for i = 1:length(S)
    S(i) = (1/Pb(i))/sqrt(sum(isfinite(P((i-1)*nb+1 : i*nb))));%essentially 1/Pb /sqrt(nb)
end
Sf = S(ind);

%fitfcn = @(x)(1./Lorentzian(x,Fbf) - 1./Pbf) ./ Sf;
%fitfcn = @(x)(Lorentzian(x,Fbf) - Pbf) .* Sf;
fitfcn = @(x)(Lorentzian(x,Fbf,[Fs nAlias]) - Pbf) .* Sf;
% options = optimoptions(@lsqcurvefit);
% options.OptimalityTolerance = 1e-30;
% options.FunctionTolerance = 1e-50;
% options.StepTolerance = 1e-50;
% options.MaxFunctionEvaluations = 1e4;
% options.MaxIterations = 1e5;
% options.Display = 'none';

options = optimoptions(@lsqnonlin);
% options.OptimalityTolerance = 1e-30;
% options.FunctionTolerance = 1e-50;
% options.StepTolerance = 1e-50;
options.MaxFunctionEvaluations = 1e4;
options.MaxIterations = 1e4;
%options.Display = 'none';
out = lsqnonlin(fitfcn, Guess,[],[],options);

%Issue may be that f3 is so large - maybe write in terms of Fs? (introduce a hard coded var, though)
% out = lsqcurvefit(@Lorentzian, Guess, Fbf, Pbf, lb, ub, options);
figure
loglog(Fbf,(Pbf),'o')
hold on
loglog(Fbf, (Lorentzian(out,Fbf, [Fs nAlias])))
out(3) = (out(3)^2+1)^-.5;
fprintf('Guess: %0.2f %0.2f %0.2f %0.2f \n  Fit: %0.2f %0.2f %0.2f %0.2f\n',Guess(1),Guess(2),Guess(3),Guess(4),out(1),out(2),out(3),out(4))

dC = 6*pi*wV*ra; %Bead drag coefficient
D = kT/dC;
a = sqrt(D/out(2));
k = 2*pi*dC*out(1);

fprintf('Bead params %0.3f %0.3f %0.3f\n', k, a, a*k)

function outdata = binValues(data, binind)
len = length(binind)-1;
outdata = zeros(1,len);
for i = 1:len
    outdata(i) = mean(data(binind(i):binind(i+1)-1));
end
