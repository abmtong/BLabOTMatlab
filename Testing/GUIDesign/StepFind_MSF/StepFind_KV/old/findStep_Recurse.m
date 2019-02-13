function outInd = findStep_Recurse( inContour, startInd, inPenalty )
%Recursively applies the Kalafut-Visscher method to detect steps.
%startInd keeps track of where we are (so outInd makes sense), since inContour will be chopped up as we recurse

len = length(inContour);

%ptVar is the variance ofadding a step at that point
%ptVar(1) 'adds' a step where there already was one- does nothing
ptQErr = zeros(1,len);

%Loop over the points and calculate the new total variance if a step was placed there
for i = 1:len
    %Quadratic error = var*(N-1)
    ptQErr(i) = C_var(inContour(1:i-1))*(i-2) + C_var(inContour(i:end))*(len-1);
    %Note: @C_var doesn't mind NaN or Inf (it returns 0, which is fine), but matlab @var doesn't
end

[optQErr, optInd] = min(ptQErr);

%The difference in SIC is the change in variance plus the penalty factor - if this is negative, the step is good
if optQErr - ptQErr(1) + inPenalty < 0 %ptVar(1) is the original variance
    %Assign the index and test the segments before and after for steps
    newInd = startInd+optInd-1;
    outInd = [findStep_Recurse(inContour(1:optInd-1),startInd,       inPenalty) ...
              newInd ...
              findStep_Recurse(inContour(optInd:end),newInd,inPenalty)];
else
    %No step, so end recursion
    outInd = [];
end