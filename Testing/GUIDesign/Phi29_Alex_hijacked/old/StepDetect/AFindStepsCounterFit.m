function [outInd, outMean] = AFindStepsCounterFit(inContour, maxSteps, inPenalty )
%Takes a Phi29 trace data and applies the Klafut-Visscher (see @calculateSIC) method to find the stepping indices
%Perform this by checking test points to bifurcate the data, creating a step before and after with the mean as the height
%Scoring is minimal variance with a small penalty for each added step to prevent overfitting

%ANotes: Can searching be optimized? Probably not, minima are very shallow, esp early on

if nargin < 3
    inPenalty = 1;
end
if nargin < 2
    maxSteps = 100;
end

% 'curr*' vs 'test*' are for before/after adding a step
testInd = [1 length(inContour)];
testVar = var(inContour);
testSIC = calculateSIC(testVar, testInd(end), inPenalty);
testXSIC = testCounterfit(inContour, testInd)-testSIC;
stepNum = 0;

SIC(1) = testSIC;
XSIC(1) = testXSIC;

fprintf(['|SIC:' num2str(testSIC) '|CalcTime:' num2str(0) '|Step:' num2str(0) '\n']);

startT = tic;

while true
    cycleT = tic;
    stepNum = stepNum + 1;
    currInd = testInd;
    currVar = testVar;
    currSIC = testSIC;
    currXSIC = testXSIC;
    [testInd, testVar] = findStep(inContour, currInd, currVar);
    testSIC = calculateSIC(testVar,length(inContour),inPenalty);
    SIC(stepNum+1) = testSIC;
    testXSIC = testCounterfit(inContour, currInd) - testSIC;
    XSIC(stepNum+1) = testXSIC;
    fprintf(['|SIC:' num2str(testSIC) '|xSIC:' num2str(testXSIC) '|CalcTime:' num2str(toc(cycleT)) '|Step:' num2str(stepNum) '\n']);
    if currSIC < testSIC
        fprintf(['Found ' num2str(stepNum-1) ' steps in ' num2str(toc(startT)) 'seconds, or ' num2str(stepNum/toc(startT)) 'steps/s. Penalty = ' num2str(inPenalty) '*' num2str(log(length(inContour))) '=' num2str(inPenalty*log(length(inContour))) '\n']);
        break;
    end
    if stepNum > maxSteps
        fprintf(['Found the maximum allowed steps, ' num2str(stepNum-1) ', in ' num2str(toc(startT)) 'seconds, or ' num2str(stepNum/toc(startT)) 'steps/s. Penalty = ' num2str(inPenalty) '*' num2str(log(length(inContour))) '=' num2str(inPenalty*log(length(inContour))) '\n']);
        break;
    end
%     if currXSIC > testXSIC
%         fprintf(['Ended since counterfit gains were less. Found ' num2str(stepNum-1) ' steps in ' num2str(toc(startT)) 'seconds, or ' num2str(stepNum/toc(startT)) 'steps/s. Penalty = ' num2str(inPenalty) '*' num2str(log(length(inContour))) '=' num2str(inPenalty*log(length(inContour))) '\n']);
%         break;
%     end
end

outInd = currInd;

%Calculate means - the step heights
outMean = zeros(1,length(outInd)-1);
for i = 1:length(outMean)
    outMean(i) = mean(inContour(outInd(i):outInd(i+1)));
end

plotStepFit(1:length(inContour),inContour,outMean,currInd);

figure('Name','SIC vs XSIC')
len = length(SIC);
plot(1:len,SIC,1:len,SIC-XSIC,1:len,XSIC)

end