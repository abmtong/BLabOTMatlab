function [outDVr, outInd] = findStep_Segment(inContour)
len = length(inContour);
ptVar = zeros(1,len);
for i = 1:len
    ptVar(i) = C_var(inContour(1:i-1)) + C_var(inContour(i:end));
end
[outVar, outInd] = min(ptVar);
%Calculate the change in variance for adding the step

% %viz.
% plot(inContour - mean(inContour) + mean(ptVar) - ptVar(1)), hold on, plot(ptVar-ptVar(1)); hold off
% text(outInd, outVar-ptVar(1), 'min')

outDVr = outVar - ptVar(1);