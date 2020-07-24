close all
%params
sig = 10; %signal
snr = 1;%snr
nstep = 30;
w = 150; %MSF window width
w2 = 1; %filter window width


[testTrace, testTr, in] = genTestTrace(snr,nstep);
%filter
step = sum(in > w & in < length(testTrace) - w + 1);
testTrace = windowFilter(@mean, testTrace, w2);

[ind,mea,tra,an] = findStep_MSF(testTrace, w, 1);

% %plot MSF
% figure
% plot(an)
% hold on
% mx = max(an);
% for i = 2:length(in)-1
%     line( [1 1] * in(i), [-mx/5 0],'Color',[1 0 0]);
% end

%Plot traces
annotateTest(testTrace, testTr, ind, mea, tra)

fprintf('There should be %d steps, e.noi = %0.1f %0.1f\n',step, estimateNoise(testTrace), estimateNoise(testTrace,250))