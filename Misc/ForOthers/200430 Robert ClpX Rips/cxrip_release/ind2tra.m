function outTrace = ind2tra(inInd, inMean)
%Converts step positions, heights to a plottable trace

outTrace = zeros(1,inInd(end));
for i = 1:length(inInd)-1
    outTrace(inInd(i):inInd(i+1)) = inMean(i);
end