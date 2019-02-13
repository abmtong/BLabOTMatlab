function outMean = ind2mea(inInd, inCon)
%Converts step positions, trace into step heights

outMean = zeros(1,length(inInd)-1);
for i = 1:length(outMean)
    outMean(i) = mean(inCon(inInd(i):inInd(i+1)-1));
end