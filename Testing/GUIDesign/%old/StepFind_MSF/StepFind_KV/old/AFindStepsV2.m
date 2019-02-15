function [outInd, outMean, outTra] = AFindStepsV2(inContour, inPenalty )
%AFindSteps(inContour, maxSteps, inPenalty )
%Takes a Phi29 trace data and applies the Klafut-Visscher (see @calculateSIC) method to find the stepping indices
%Perform this by checking test points to bifurcate the data, creating a step before and after with the mean as the height
%Scoring is minimal variance with a small penalty for each added step
%Now uses C code to calculate variance
%V2: Passes along the best variance for the segments that didn't get picked
%#Calls to var used to be length*numSteps, now should just be 2*length

if nargin < 2
    inPenalty = 1 * log(length(inContour));
end

%Uses C++ code to calculate variance, get ~3x speedup. Requires double array, P29 traces are single arrays.
inContour = double(inContour);
len = length(inContour);

%A note on variable names
%Arrays prefixed with 'seg' mean optimal parameters per step segment.
%So the optimal place to put a step at the third dwell is at segInd(3) and it yields a change of segDVr(3) in variance.
%Scalars prefixed with 'new' are newly calculated values: segInd and segDVr of the two new steps made last iteration
%outInd is the current stepping solution.

%First step needs to be done outside the loop, since there's only one unknown region
[segDVr, segInd] = findStep_Segment(inContour(1:end-1)); %1:end-1 for consistency with next uses
segVar = C_var(inContour);
%Calculate 'SIC', or at least all we need to calculte in order to make a comparison
oldSIC = len*log(segVar);
newSIC = len*log(segVar + segDVr) + inPenalty;
%If we can't find a better SIC, we're done
if newSIC - oldSIC > 0
    outInd = [1 len];
    outMean = mean(inContour);
    return;
end
%First step accepted, update values
oldSIC = newSIC;
outInd = [1 segInd len];
segVar = [C_var(inContour(1:segInd-1)) C_var(inContour(segInd:end-1))];
newInd = 1; %Indicates the index of the last placed step.

startT = tic;
while true
    %Expand our holder variables
    
    %Sanity check: Ignore steps of width 2 or smaller, throws an error otherwise
    if outInd(newInd+1) - outInd(newInd) > 2
        [newDVr1, newInd1] = findStep_Segment(inContour(outInd(newInd)  :outInd(newInd+1)  -1));
    else
        newDVr1 = Inf;
        newInd1 = Inf;
    end
    if outInd(newInd+2) - outInd(newInd+1) > 2
        [newDVr2, newInd2] = findStep_Segment(inContour(outInd(newInd+1):outInd(newInd+2)-1));
    else
        newDVr2 = Inf;
        newInd2 = Inf;
    end
    %newInd is relative to the segment passed to findStep_Segment, so convert to absolute index
    newInd1 = newInd1 + outInd(newInd)  -1;
    newInd2 = newInd2 + outInd(newInd+1)-1;
    
    %Insert new values into the arrays
    segInd = [segInd(1:newInd-1) newInd1 newInd2 segInd(newInd+1:end)];
    segDVr = [segDVr(1:newInd-1) newDVr1 newDVr2 segDVr(newInd+1:end)];
    
    %Find the best change in variance, which corresponds to the best change in SIC
    [minDVr, newInd] = min(segDVr);
    
    %Calculate the new 'SIC' = len(ln(var)) + penalty -- all we need to compare two states
    newSIC = len*log((sum(segVar) + minDVr)) + inPenalty;
    %Compare: If we can't come up with a better SIC, we're done.
    if newSIC >= oldSIC
        break;
    end
    oldSIC = newSIC;
    
    %Step accepted, add the step to outInd, variance to segVar
    outInd = [outInd(1:newInd) ...
              segInd(newInd) ...
              outInd(newInd+1:end)];
    segVar = [segVar(1:newInd-1) ...
              C_var(inContour(outInd(newInd)  :outInd(newInd+1)-1)) ...
              C_var(inContour(outInd(newInd+1):outInd(newInd+2)-1)) ...
              segVar(newInd+1:end)];
end

%Calculate means - the step heights
outMean = zeros(1,length(outInd)-1);
for i = 1:length(outMean)
    outMean(i) = mean(inContour(outInd(i):outInd(i+1)));
end
outTra = ind2tra(outInd, outMean);

fprintf(['K-V: Found ' num2str(length(outMean)-1) 'st over ' num2str(roundn(outMean(1)-outMean(end),-1)) 'bp in ' num2str(roundn(toc(startT),-2)) 's.  Penalty = ' num2str(inPenalty) ', cf ' num2str(log(length(inContour))) '\n']);
end