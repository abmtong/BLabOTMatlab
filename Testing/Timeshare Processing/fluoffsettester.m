function out = fluoffsettester


ft = 1e3;
ff = 20;

%Underlying signal at 1MHz
%Total points is 1e6 = 0.1s
%Crosses at some random pt between first and last cycle
tcr = 2e5 + round(rand*5e5);
sig = zeros(1,1e6);
sig(tcr:end) = 1;

%Downsample
trap = windowFilter(@mean, sig, [], 1000);

%Add random delay to fluorescence
fluor = windowFilter(@mean, [zeros(1, randi(50e3)) sig], [],50e3);

%Find crossing pts
ttr = find(trap > .5, 1, 'first');
tfl = find(fluor > .5, 1, 'first');

fprintf('Crosses at %0.4f, %0.4f\n', ttr / ft, (tfl+1) / ff)
