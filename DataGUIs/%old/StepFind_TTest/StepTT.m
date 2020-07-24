function [ outInd, outMea, outTra ] = StepTT( inContour, inThr, inWid)
%STEPTT Summary of this function goes here
if nargin < 3
    inWid = 10;
end

if nargin < 2
    inThr = 0.6;
end

%     function outT = tt(data)
%         m = round(length(data)/2);
%         [~, outT] = ttest2(data(1:m), data(m+1:end));
%     end

    function outT = tt(data)
        m = round(length(data)/2);
        [~, ~, ~, stats] = ttest2(data(1:m), data(m+1:end));
        outT = abs(stats.tstat);
    end


twin = windowFilter(@tt, inContour, inWid, 1);
%figure, findpeaks(double(abs(twin)), 'MinPeakHeight', inThr, 'MinPeakProminence',inThr/2);
[~, loc] = findpeaks(double(twin), 'MinPeakHeight', inThr, 'MinPeakProminence',inThr/2);
outInd = [1 loc length(inContour)];

outMea = ind2mea(outInd, inContour);
outTra = ind2tra(outInd, outMea);
fprintf('\b|\n')
end

