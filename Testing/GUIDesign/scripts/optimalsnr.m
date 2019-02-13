function optimalsnr()
%perfect staircase, muddled by 35pN-ish noise
bupt = 100;
snr=0.8;
sig = 2.5;

tr = [zeros(1,bupt) sig*ones(1, bupt) sig*2*ones(1, bupt) sig*3*ones(1,bupt) sig*4*ones(1,bupt)];
no = randn(1, length(tr)) * sig/snr;
tr = fliplr(tr);
figure, plot(tr+no), hold on, plot(smooth(tr+no))%, hold on, plot(fliplr(tr))
