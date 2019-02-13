function [outTrNoi, outTr, outInd] = testTrSm(innoi, inNumSteps)

if nargin < 2
    inNumSteps = 100;
end

if nargin < 1
    innoi = 2;
end

startCon = 8000;

%define staircase sizes (repeats the matrix)
st = [2.5 2.5 2.5 1.1];
% st = 2.5*ones(1,4);
% st = 8.6 /4 * ones(1,4);

%step lengths (s) - normally distributed (probably should use e.g. gamma dist, but w/e)
dwmu = 0.05 * 2500;
dwsg = dwmu*.7; %chance of normcdf( -dwmu, dwmu, dwsg ) to skip a step
%dwells will be a tad longer
dwmult = 1.5; %2 seems to match Moffit's data
%drift (bp per sec)
drft = .0;
%signal blur (pts)
blurwid = 5;


steps = cumsum([startCon repmat(st, 1, round(inNumSteps/length(st)))]);
% steps = startCon:-sig:startCon-sig*inNumSteps;
n = length(steps);
%normally distributed lengths
lengths = round(dwmu + dwsg*randn(1,n));
%make dwells (every 4th) longer
lengths(1:4:n) = round(lengths(1:4:n)*dwmult);
%zero out negative lengths - these will be skipped (missed, in essence)
lengths(lengths < 0) = 0;
%Create array of indices
outInd = [0 cumsum(lengths)] + 1;
len = outInd(end);

%noise vector, = random noise + drift
noi = randn(1,len)*innoi + (1:len)/2500 * drft;

%assemble
outTr = zeros(1,len);
for i = 1:n
    outTr(outInd(i):outInd(i+1)) = steps(i);
end

%blur the signal, apply noise
outTrNoi = smooth(outTr, blurwid)' + noi;