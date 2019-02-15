function [outTrNoi, outTr, outInd] = genTestTrace(inSNR, inNumSteps)

if nargin < 2
    inNumSteps = 30;
end

startCon = 8000;
sig = 10; %signal

%create whatever
steps = startCon:-sig:startCon-sig*inNumSteps;
n = length(steps);
%normally distributed lengths (mean 300, sd 100)
lengths = 200 + round(100*randn(1,n));
%any that are nonpositive, set positive
lengths(lengths <= 50) = 50;
%Create array of indices
outInd = [1 cumsum(lengths)];
len = outInd(end);

%noise vector
noi = randn(1,len)*sig/inSNR;
%assemble
outTr = zeros(1,len);
for i = 1:n
    outTr(outInd(i):outInd(i+1)) = steps(i);
end
%apply noise
outTrNoi = outTr + noi;