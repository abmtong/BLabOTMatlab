function outNoise = estimateNoise(inContour, inWidth)
%Estimates the variance of the noise of a trace.
%Subtracts the moving average to try to remove packaging signal
%For a phi29 trace, 125/Decimation factor works well. 

if nargin < 2
    inWidth = 125;
end

inWidth = ceil(inWidth);
outNoise = var(inContour - windowFilter(@mean, inContour, inWidth));