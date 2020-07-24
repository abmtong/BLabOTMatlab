function [outInd, outMean, outTra] = AFindStepsV3(inContour, inPenalty, inMaxSteps)
%AFindSteps(inContour, maxSteps, inPenalty )
%Takes a Phi29 trace data and applies the Klafut-Visscher (see @calculateSIC) method to find the stepping indices
%Perform this by checking test points to bifurcate the data, creating a step before and after with the mean as the height
%Scoring is minimal variance with a small penalty for each added step
%Now uses C code to calculate variance
%V2: Passes along the best variance for the segments that didn't get picked
%#Calls to var used to be length*numSteps, now should just be 2*length
%V3: Work with QE and array of stored [ind, dQE]s like in ChSq

% Use V4 instead %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Defaults
if nargin < 3 || isempty(inMaxSteps)
    inMaxSteps = 100;
end

if nargin < 2 || isempty(inPenalty)
    inPenalty = 1 * log(length(inContour));
end

%Uses C++ code to calculate variance, get ~3x speedup. Requires double array, P29 traces are single arrays.
if ~isa(inContour, 'double')
    inContour = double(inContour);
end
len = length(inContour);

%Store already calculated values, in fmt [ind1 ind2 QE dQE dInd]
histData = zeros(inMaxSteps*2, 5);
findcell = @(mat, st, en)(find(mat(:,1) == st & mat(:,2) == en));

%Define a fcn that searches for the best step location (one with minimal QE)
    function [outQE, outdQE, outInd] = findStep_Segment(inCon)
        outQE = inf;
        for ii = 1:length(inCon)
            testQE = C_qe(inCon(1:ii-1)) + C_qe(inCon(ii:end));
            if testQE < outQE
                outQE = testQE;
                outInd = ii;
            end
        end
        %Calculate the change in QE for adding the step
        outdQE = outQE - C_qe(inCon);
    end

%First step needs to be done outside the loop, since there's only one unknown region
[segDVr, segInd] = findStep_Segment(inContour(1:end-1)); %1:end-1 for consistency with next uses
segVar = C_qe(inContour);
%Calculate 'SIC', or at least all we need to calculte in order to make a comparison
oldSIC = len*log(segVar/len);
newSIC = len*log((segVar + segDVr)/len) + inPenalty;
%If we can't find a better SIC, end early
if newSIC - oldSIC > 0
    outInd = [1 len];
    outMean = mean(inContour);
    return;
end
%First step accepted, update values
oldSIC = newSIC;
outInd = [1 segInd len];
segVar = [C_qe(inContour(1:segInd-1)) C_qe(inContour(segInd:end-1))];
newInd = 1; %Indicates the index of the last placed step.

startT = tic;
while true
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
    newSIC = len*log((sum(segVar) + minDVr)/len) + inPenalty;
    %Compare: If we can't come up with a better SIC, we're done.
    if newSIC >= oldSIC
        break;
    end
    oldSIC = newSIC;
    
    %Step accepted, add the step to outInd, variance to segVar
    outInd = [outInd(1:newInd) ...
              segInd(newInd) ...
              outInd(newInd+1:end)];
    %Might not bother storing QE of these- only O(nstep^2), cf O(npts^2) which the finding depends on
    segVar = [segVar(1:newInd-1) ...
              C_qe(inContour(outInd(newInd)  :outInd(newInd+1)-1)) ...
              C_qe(inContour(outInd(newInd+1):outInd(newInd+2)-1)) ...
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