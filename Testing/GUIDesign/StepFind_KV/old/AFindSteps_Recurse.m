function [outInd, outMean] = AFindSteps_Recurse(inContour, inPenalty )
%AFindSteps(inContour, maxSteps, inPenalty )
%Takes a Phi29 trace data and applies the Klafut-Visscher (see @calculateSIC) method to find the stepping indices
%Perform this by checking test points to bifurcate the data, creating a step before and after with the mean as the height
%Scoring is minimal variance with a small penalty for each added step
%Now uses C code to calculate variance

%V2: Rewriting SIC as [quadratic error + step penalty], should be able to implement a recursive search
%%Unfinished

if nargin < 2
    inPenalty = 1 * log(length(inContour));
end

%Uses C++ code to calculate variance, get ~3x speedup. Requires double array.
inContour = double(inContour);

startT = tic;

outInd = [1 findStep_Recurse(inContour, 1, inPenalty) length(inContour)];

%Calculate means - the step heights
outMean = zeros(1,length(outInd)-1);
for i = 1:length(outMean)
    outMean(i) = mean(inContour(outInd(i):outInd(i+1)));
end

fprintf(['K-V: Found ' num2str(length(outMean)-1) 'st over ' num2str(roundn(outMean(1)-outMean(end),-1)) 'bp in ' num2str(roundn(toc(startT),-2)) 's.  Penalty = ' num2str(inPenalty) ', cf ' num2str(log(length(inContour))) '\n']);
end