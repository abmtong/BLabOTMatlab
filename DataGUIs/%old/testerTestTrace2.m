close all
testTrace2 = windowFilter(@mean, testTrace, 3);
[in,me,tr] =findStepsChiSq(testTrace2);
line(n-1*[1 1], [1 1.5])
figure
plottt(testTrace2, testTr, tr)
hold on
for i = 1:length(me)
    line(in(i+1)*[1 1]+ [0 5*len/(steps(1)-steps(end))],me(i)*[1 1] + [0 10])
end
fprintf('There should be %d steps\n',n-1)
fprintf('%0.2f %0.2f\n',estimateNoise(testTrace), estimateNoise(testTrace2))