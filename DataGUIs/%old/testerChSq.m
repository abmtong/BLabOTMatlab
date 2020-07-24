close all
%params
sig = 10; %signal
snr = 1;%snr
nstep = 30;

[testTrace, testTr] = genTestTrace(snr,30);
%filter
testTrace = windowFilter(@mean, testTrace, 1);

figure
subplot(4,2,1)
[in,me,tr,s] =findStepsChiSq(testTrace);
line(30*[1 1], [1 2])
subplot(4,2,2)
[~,~,~,s2] = findStepsChiSqV2(testTrace);
line(30*[1 1], [1 2])
subplot(4,2,3:8)
plottt(testTrace, testTr, tr)

hold on
for i = 1:length(me)
    line(in(i+1)*[1 1]+ [-1 50],me(i)*[1 1] + [0 20])
end

% subplot(4,2,7)
% findpeaks(s,'Annotate','extents')
% subplot(4,2,8)
% findpeaks(s2,'Annotate','extents')

fprintf('There should be %d steps, e.noi = %0.1f %0.1f\n',nstep, estimateNoise(testTrace), estimateNoise(testTrace,250))