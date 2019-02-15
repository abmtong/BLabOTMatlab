function [outInd, outMean] = tra2ind(inTrace)
%Converts the output from Aggarwal to KV method

tempInd = [1 find(diff(inTrace) ~= 0)+1];
outMean = inTrace(tempInd);
outInd = [tempInd length(inTrace)];