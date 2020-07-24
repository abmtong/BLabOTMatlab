function [outInd, outMean] = AFindStepsRecurse(inContour, inPenalty)
%Takes a trace Contour and applies the Klafut-Visscher method to find the stepping indices. Uses a recursive algorithm.
%Perform this by checking test points to bifurcate the data, creating a step before and after with the mean as the height
%Scoring is minimal variance with a small penalty for each added step.

%Can choose to use a PenaltyFactor (multiple of logn) or just a raw Penalty

%Variance of contour changes with  - use extension instead?

if nargin < 2
    inPenalty = 1;
end

startT = tic;

outInd = findStepRecurse(1, inContour, inPenalty);

calcTime = toc(startT);
numSteps = length(outInd);
rate = numSteps/calcTime;
fprintf(['|CalcTime:' num2str(calcTime) '|Steps:' num2str(numSteps) '|Rate:' num2str(rate) '\n']);

outInd = [ 1 outInd length(inContour) ] ;

%Calculate means - the step heights
outMean = zeros(1,length(outInd)-1);
for i = 1:length(outMean)
    outMean(i) = mean(inContour(outInd(i):outInd(i+1)));
end

plotStepFit(1:length(inContour),inContour,outMean,outInd);

end