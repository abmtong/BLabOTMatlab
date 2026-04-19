function out = ppstest()
%

%Generate test trace


frc = 4; %pN

%Signal, nm
snl = 1;

%Noise(f), nm
noiwin = [5 1 1]; %Noise at 1pN, asymptotic noise at 30pN, scale factor
noi = @(f) (noiwin(1)-noiwin(2))./f * noiwin(3) + noiwin(2);

Fs = 1e5; %Fsamp
Fc = 1e4; %Fc, take this as 'filter signal with moving average of this amount'

k = 1e3; %k_fold and k_unfold, say we're at f 1/2


%Generate trace
kpts = Fs / k;
nstep = 10000;
dws = ceil(exprnd(kpts, 1, nstep));
in = cumsum([1 dws]);
me = mod( 1:length(in) , 2 ) * snl;

tr = ind2tra(in, me);
len = length(tr);
trfil = windowFilter(@mean, tr, ceil(Fs/Fc/2),1);
trnoi = tr + randn(1, length(tr))*noi(frc);

%Calculate power spectrum
pspec = @(x) abs(fft(x)).^2 / Fs / (length(x)-1);
ptr = pspec(tr);
ptrfil = pspec(trfil);
ptrnoi = pspec(trnoi);
ff = (0:len-1)/(len-1)*Fs;

gfb = 1.02;
plps = @(x,y) plot( geofilter( x(2:floor(end/2)), gfb), geofilter(y(2:floor(end/2)), gfb) );






figure, hold on, 
plps(ff, ptr)
plps(ff, ptrfil)
plps(ff, ptrnoi)
set(gca, 'XScale', 'log'), set(gca, 'YScale' , 'log')








