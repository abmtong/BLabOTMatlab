function outNoise = estimateNoise(inContour)
%Estimates the variance of the noise of a trace.
%Subtracts the moving average to try to normalize it first
outNoise = var(inContour - windowFilter(@mean, inContour, 125));
end

