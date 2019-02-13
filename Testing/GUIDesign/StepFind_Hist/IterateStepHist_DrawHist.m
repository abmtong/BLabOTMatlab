function IterateStepHist_DrawHist(inSSD, inYRes)
if nargin<2
    inYRes = 0.1;
end
newP = normHist(inSSD, inYRes);
figure('Name',sprintf('Step Size Histogram %s', inputname(1)));
x = newP(:,1);
y = newP(:,2);
bar(x,y)
hold on
ploty = smooth(y, 5);
plot(x,ploty,'LineWidth',1)
[pks, pkind] = findpeaks(double(ploty),'MinPeakHeight',max(ploty)/20);
pkloc= double(x(pkind));
for j = 1:length(pks)
    text(pkloc(j), pks(j), num2str(pkloc(j)))
end