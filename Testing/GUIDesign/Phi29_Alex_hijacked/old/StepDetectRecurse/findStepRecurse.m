function outInd = findStepRecurse( startInd, inContour, inPenalty )
%Recursively applies the Kalafut-Visscher method to detect steps.
%startInd keeps track of where we are (so outInd makes sense), since inContour will be chopped up as we recurse
%Works differently than the non-recursive function - here n changes as we delve deeper

%We're going to calculate the variance with a step at each point and find the minimum of the choices

if length(inContour) < 2 % If the range we're given is too small, ignore it (probably means overfitting, too)
    fprintf('Theres a step 2pt wide, potentially overfit. Try increasing the Penalty Factor\n');
    outInd = [];
    return;
end

%The differential penalty in the SIC
%penalty = inPenalty*log(length(inContour))/length(inContour); %K-V method
penalty = 9*inPenalty/length(inContour); %Aggarwal method, where penalty = 9*var(noise)

%ptVar has structure: [var(inContour) +Inf var_stepatpoint(2:length(inContour)-1)]
%This is done to improve readability of indices: ptVar(i) is the variance if a step was placed at the ith point.
%Adjacent steps don't really make sense, so ignore them [--less objective]
ptVar = zeros(1,length(inContour)-1);
ptVar(1) = var(inContour);
ptVar(2) = Inf;

%Loop over the points and calculate the new total variance if a step was placed [one point after] there
for i = 3:length(ptVar)
    % New variance = var(first part) + var(second part)
    ptVar(i) = var(inContour(1:i-1)) + var(inContour(i:end));
end

[optVar, optInd] = min(ptVar);

%The difference in SIC is the change in variance plus the penalty factor - if this is negative, the step is good
if optVar - ptVar(1) + penalty < 0 %ptVar(1) is the original variance
    %Assign the index and test the segments before and after for steps
    outInd = [findStepRecurse(startInd,inContour(1:optInd-1),inPenalty) ...
              startInd+optInd ...
              findStepRecurse(startInd+optInd,inContour(optInd:end),inPenalty)];
else
    outInd = [];
end

end