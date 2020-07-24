function [outInd, outVar] = findStep( inContour, inInd, inVar )
%Takes a state stepData and attempts placing a step at every point from [1, length(inContour)] and outputs the best choice by minimizing the total variance

len = length(inVar);
%We're going to calculate the SIC segment-by-segment and find the minimum at the end
segVar = zeros(1,len);
newVar = zeros(1,len);
segInd = zeros(1,len);

%Loop over each currently existing step
for i = 1:length(inVar)
    %The change in SIC is purely dependent on the variance, so just store the new variance of the segment at each point
    conSlice = inContour(inInd(i):inInd(i+1));
    wid = length(conSlice);
    pointVars = zeros(1, wid);
    for j = 1:wid
        pointVars(j) = var(conSlice(1:j-1)) + var(conSlice(j:end)); 
    end
    
    if isempty(pointVars) %If len = 0, pointVars is empty throwing an error. Just set to +Inf; it will never be chosen
        segVar(i) = Inf;
        segInd(i) = Inf;
        newVar(i) = Inf;
    else
        %Find the smallest variance
        [segVar(i), segInd(i)] = min(pointVars);
        %Calculate the change in variance for adding the step
        newVar(i) = segVar(i) - inVar(i);
    end
end

%Find the best change in variance
[~, minInd] = min(newVar);

%Assemble our new Ind, Vars
outInd = [inInd(1:minInd) ...
            inInd(minInd)+segInd(minInd) ...
            inInd(minInd+1:end)];
outVar = [inVar(1:minInd-1) ...
            var(inContour(inInd(minInd)         : inInd(minInd) + segInd(minInd)))...
            var(inContour(inInd(minInd) + segInd(minInd) + 1 : inInd(minInd+1)  ))...
            inVar(minInd+1:end)];
end