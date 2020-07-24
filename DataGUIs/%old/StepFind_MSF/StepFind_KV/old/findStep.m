function [outInd, outVar] = findStep( inContour, inInd, inVar )
%Takes a state stepData and attempts placing a step at every point from [1, length(inContour)] and outputs the best choice by minimizing the total variance

%We're going to calculate the SIC segment-by-segment and find the minimum at the end
segVar = zeros(1,length(inVar));
newVar = zeros(1,length(inVar));
segInd = zeros(1,length(inVar));

%Loop over each currently existing dwell
for i = 1:length(inVar)
    %The change in SIC is purely dependent on the variance, so just store the new variance of the segment at each point
    
    %Allocate an array with a spot for each point between inInd(i) and inInd(i+1)
    len = inInd(i+1) - inInd(i) - 1;
    pointVars = zeros(1, len);
    
    %if len == 0, we can't place a step here, so just set to +Inf so it will never be chosen
    if len == 0
        segVar(i) = Inf;
        segInd(i) = Inf;
        newVar(i) = Inf;
    else
        %Calculate the variance for the segment with the step
        for j = 1:len
                pointVars(j) = C_var(inContour(inInd(i)     : inInd(i) + j - 1)) ...
                             + C_var(inContour(inInd(i) + j : inInd(i+1) - 1));
        end

        %Find the smallest variance in the search
        [segVar(i), segInd(i)] = min(pointVars);
        %Calculate the change in variance for adding the step
        newVar(i) = segVar(i) - inVar(i); 
    end
end

%Find the best change in variance
[~, minInd] = min(newVar);

%Assemble our new Ind, Vars
newInd = segInd(minInd);
outInd = [inInd(1:minInd) ...
            inInd(minInd)+newInd ...
            inInd(minInd+1:end)];
outVar = [inVar(1:minInd-1) ...
            C_var(inContour(inInd(minInd)          : inInd(minInd) + newInd - 1))...
            C_var(inContour(inInd(minInd) + newInd : inInd(minInd+1) -1 ))...
            inVar(minInd+1:end)];
end