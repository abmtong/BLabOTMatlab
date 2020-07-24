function [outPWD, outX] = sumPWDV2(inData, sd, bin)
%Takes in cell of traces inData calc.s PWD at a given 

if nargin < 3
    bin = 0.1;
end
if nargin<2
    sd = 0.5;
end

if ~iscell(inData)
    inData = {inData};
end

if ~isa(inData{1}, 'double')
    inData = cellfun(@double,inData,'uni',0);
end
len = length(inData);
figure('Position',[0 0 1000 500]);

wid = 50;
pts = round(wid/bin+1);

outX = 0:bin:wid;
outPWD = zeros(1,pts);
for i = 1:len
    [p, ~] = calcPWDV2(inData{i}, bin, sd);
%     p = smooth(p,10);
    if length(p) < pts
        p = [p p(end)*ones(1,pts)]; %#ok<AGROW>
    end
    outPWD = outPWD + p(1:pts);
end
%findpeaks(outPWD, outX)
plot(outX,outPWD)
[pk, lc] = findpeaks(outPWD, outX);
hold on
plot(lc, pk, 'o', 'MarkerSize', 12)
for i = 1:length(pk)
    text(lc(i), pk(i), sprintf('%0.2f',lc(i)))
end
ind = find(diff(outPWD)>0, 1);
ylim([min(outPWD(ind:end)), max(outPWD(ind:end))])
xlim([0 outX(end)])

