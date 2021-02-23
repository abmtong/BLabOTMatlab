function out = shortPWDtester()

%Can we extract PWD information from a trace snippet only ~3 repeats long?

%Generate trace
noi = .5;
dw = 100;
tr = [ones(1,dw) ones(1,dw)*2 ones(1,dw)*3];
tr = tr + randn(1,length(tr))*noi;
tr = tr + sin( (1:length(tr))*.1) * noi/2;

%Smooth
wid = 50;
tr = smooth(tr,wid)';

%Make KDF
dy = 1e-3;
[kdy, kdx] = kdf(tr, dy, 0);

%Pad with zeros
nz = 1e6;
kdy0 = [kdy ones(1,nz)*mean(kdy)];

%Calculate PWD
hei = length(kdy0);
Fs = 1/dy;
pwd = ifft(abs(fft(kdy0).^2))/Fs/(hei-1);
pwx = (0:hei-1)*dy;

figure
subplot(3,1,1), plot(tr)
subplot(3,1,2), plot(kdx, kdy)
subplot(3,1,3), plot(pwx, pwd)
axis tight
xlim([0.1 4])