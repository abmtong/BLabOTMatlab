function [outPWD, outX] = plotPWDV2cell(inData, bin, sd)
%Takes in cell of traces inData calc.s PWD at a given 

if nargin < 3
    sd = 0.5;
end

if nargin < 2
    bin = 0.1;
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

wid = 50; %in bp

outX = 0:bin:wid;
pts = length(outX);
outPWD = zeros(len,pts);
for i = 1:len
    [p, ~] = calcPWDV2(inData{i}, bin, sd);
%     p = smooth(p,10);
    if length(p) < pts
        p = [p p(end)*ones(1,pts)]; %#ok<AGROW>
    end
    outPWD(i,:) = p(1:pts);
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
% plot(lc, pk, 'o', 'MarkerSize', 12)
for i = 1:length(pk)
    text(lc(i), pk(i), sprintf('%0.2f',lc(i)))
end
ind = find(diff(outPWD)>0, 1);
ylim([min(outPWD(ind:end)), max(outPWD(ind:end))])

