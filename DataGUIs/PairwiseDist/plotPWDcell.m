function [outPWD, outX] = plotPWDcell(inData, filspan, bin)
%Takes in cell of traces inData calc.s PWD at a given 

if nargin < 3
    bin = 0.25;
end
if nargin<2
    filspan = 20;
end

if ~iscell(inData)
    inData = {inData};
end

if ~isa(inData{1}, 'double')
    inData = cellfun(@double,inData,'uni',0);
end
len = length(inData);
figure('Position',[0 0 1000 500]);
hold on

wid = 50;
pts = round(wid/bin+1);

outX = 0:bin:wid;
outPWD = zeros(len,pts);
for i = 1:len
    %filter
    dfil = smooth(inData{i},filspan);
    [p, ~] = calcPWD(dfil, bin);
    p = smooth(p,10);
    if length(p) < pts
        p = [p; p(end)*ones(pts,1)]; %#ok<AGROW>
    end
    outPWD(i,:) = p(1:pts)';
end
%findpeaks(outPWD, outX)

for i = 1:len
    plot(outX,outPWD(i,:))
end
outPWD = sum(outPWD);
[pk, lc] = findpeaks(outPWD, outX);
pkmax = outPWD(1);
outPWD = outPWD/pkmax;
pk = pk/pkmax;
plot(outX, outPWD, 'LineWidth', 2)
for i = 1:length(pk)
    text(lc(i), pk(i), sprintf('%0.2f',lc(i)))
end
ind = find(diff(outPWD)>0, 1);
ylim([min(outPWD(ind:end)), max(outPWD(ind:end))])

