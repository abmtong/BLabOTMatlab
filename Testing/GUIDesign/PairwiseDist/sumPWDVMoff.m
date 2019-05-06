function [outPWD, x] = sumPWDVMoff(inData, fil, binszn)
%argout  = [outPWD, outX]
%Takes in cell of traces inData calc.s PWD

if nargin < 3
    binszn = [0.05 200];
end
if nargin<2
    fil = 5;
end

if ~iscell(inData)
    inData = {inData};
end

if ~isa(inData{1}, 'double')
    inData = cellfun(@double,inData,'uni',0);
end
len = length(inData);
figure('Name', sprintf('sumPWD dat:%s fil:%d bin:%0.2f', inputname(1), fil, binszn(1)), 'Position',[0 0 1000 500]);

outPWD = zeros(1,binszn(2));
for i = 1:len
    %check for NaN (Ghe code had some NaN, bc some F is negative)
    if any(isnan(inData{i}))
        if all(isnan(inData{i}))
            continue
        else %rm nans if there is non-nan data
            inData{i} = inData{i}( ~isnan(inData{i}) );
        end
    end
    [p, x] = calcPWDVMoff(inData{i}, fil, binszn);

    if length(p) < binszn(2)
        p = [p p(end)*ones(1,binszn(2))]; %#ok<AGROW>
    end
    outPWD = outPWD + p(1:binszn(2));
end
%findpeaks(outPWD, outX)
plot(x,outPWD)
[pk, lc] = findpeaks(outPWD, x);
for i = 1:length(pk)
    text(lc(i), pk(i), sprintf('%0.2f',lc(i)))
end
ind = find(diff(outPWD)>0, 1);
if isempty(ind)
    ind = min(5, length(outPWD));
end
ylim([min(outPWD(ind:end)), eps+max(outPWD(ind:end))])
xlim([0 x(end)])



