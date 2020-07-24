function exampleacorr()

%Say hopping is sd 1 with difference
dmu = 4;

%And switch probability of:
ps = 1e-2;

%Trace length
n = 2^20;

st = rand(1,n) < ps;
st = mod(cumsum(st),2);
st = st*dmu;

%Smooth the pure signal by a bit
wid = 5;
st = smooth(st,wid)';

%Add noise, shift to zero
noi = randn(size(st));
st = st + noi - dmu/2;

figure, plot(st);
xlim([0 50/ps])

stac = xcorr(st);
stac = stac(n:end);
noac = xcorr(noi);
noac = noac(n:end);

figure, plot(stac)
hold on, plot(noac)
xlim([1 300])

