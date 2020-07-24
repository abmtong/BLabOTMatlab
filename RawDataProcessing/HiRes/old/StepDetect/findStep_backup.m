function [outInd, outVar] = findStep( inContour, inInd, inVar )
%Takes a state stepData and attempts placing a step at every point from [1, length(inContour)] and outputs the best choice by minimizing the total variance

%We're going to calculate the SIC segment-by-segment and find the minimum at the end
segVar = zeros(1,length(inVar));
newVar = zeros(1,length(inVar));
segInd = zeros(1,length(inVar));

%Loop over each currently existing step
for i = 1:length(inVar)
    %The change in SIC is purely dependent on the variance, so just store the new variance of the segment at each point
    
    %Allocate an array with a spot for each point between inInd(i) and inInd(i+1)
    len = inInd(i+1) - inInd(i) - 1;
    %%Right now if len = 0, an error is thrown below (see %%). I think that's okay, as it probably means overfitting
    
    %A one-length "step" just removes one point from the variance calculation
    
    pointVars = zeros(1, len);
    
    %Calculate the variance for the segment with the step
    for j = 1:len
            pointVars(j) = var(inContour(inInd(i)         : inInd(i) + j)) ...
                         + var(inContour(inInd(i) + j + 1 : inInd(i+1)));
    end
    
    if ~isempty(pointVars)
        %Find the smallest variance in the search
        [segVar(i), segInd(i)] = min(pointVars);
        %Calculate the change in variance for adding the step
        newVar(i) = segVar(i) - inVar(i);
    else %If len = 0, pointVars is empty throwing an error. Just set to +Inf; it will never be chosen
        segVar(i) = Inf;
        segInd(i) = Inf;
        newVar(i) = Inf;
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