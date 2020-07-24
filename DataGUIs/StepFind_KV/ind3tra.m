function outTrace = ind3tra(inInd, inContour)
%Converts step positions, data to a plottable trace

mea = ind2mea(inInd, inContour);
outTrace = ind2tra(inInd, mea);