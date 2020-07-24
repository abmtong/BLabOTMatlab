function [outInd, outMean] = AFindSteps_Drift(inContour, maxSteps, inPenalty )
%AFindSteps(inContour, maxSteps, inPenalty )
%Takes a Phi29 trace data and applies the Klafut-Visscher (see @calculateSIC) method to find the stepping indices
%Perform this by checking test points to bifurcate the data, creating a step before and after with the mean as the height
%Scoring is minimal variance with a small penalty for each added step to prevent overfitting

%ANotes: Can searching be optimized? Probably not, minima are very shallow, esp early on

if nargin < 3
    inPenalty = estimateNoise(inContour)*9;
    %inPenalty = penaltyfactor * log(length(inContour));
end
if nargin < 2
    maxSteps = 100;
end

% 'curr*' vs 'test*' are for before/after adding a step
testInd = [1 length(inContour)];
testVar = var(inContour);
testSIC = calculateSIC(testVar, testInd(end), inPenalty);
stepNum = 0;

fprintf(['|SIC:' num2str(testSIC) '|CalcTime:' num2str(0) '|Step:' num2str(0) '\n']);

startT = tic;

while true
    cycleT = tic;
    stepNum = stepNum + 1;
    currInd = testInd;
    currVar = testVar;
    currSIC = testSIC;
    [testInd, testVar] = findStep(inContour, currInd, currVar);
    testSIC = calculateSIC(testVar,length(inContour),inPenalty);
    fprintf(['|SIC:' num2str(testSIC) '|CalcTime:' num2str(toc(cycleT)) '|Step:' num2str(stepNum) '\n']);
    if currSIC < testSIC
        break;
    end
    if stepNum > maxSteps
        fprintf(['Found the maximum allowed steps. \n']);
        break;
    end
end

outInd = currInd;

%Calculate means - the step heights
outMean = zeros(1,length(outInd)-1);
for i = 1:length(outMean)
    outMean(i) = mean(inContour(outInd(i):outInd(i+1)));
end

fprintf(['Found ' num2str(stepNum-1) ' steps in ' num2str(toc(startT)) 'seconds over ' num2str(outMean(1)-outMean(end)) ' bp. Penalty = ' num2str(inPenalty) ', cf ' num2str(log(length(inContour))) '\n']);
end