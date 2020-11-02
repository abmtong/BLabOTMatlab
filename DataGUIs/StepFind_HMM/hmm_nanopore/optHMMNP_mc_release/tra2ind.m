function [outInd, outMean] = tra2ind(inTrace)
%Converts a staircase trace to just its inds and meas

tempInd = [1 find(diff(inTrace) ~= 0)+1];
outMean = inTrace(tempInd);
outInd = [tempInd length(inTrace)]; %Note that outInd(end-1) might also be length(inTrace)