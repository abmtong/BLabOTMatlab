function [out outraw] = simrnaptrace(noi, inOpts)

if nargin < 1
    noi = 3;
end

%Trace options
%RNAP is a sum of single-exponentials, with populations a(i) and rates k(i) (bp/s)
opts.a = [0.9 0.1];
opts.k = [15, 5];

%Measurement options
opts.Fs = 1e3; %FSamp
opts.resp = 10; %Response time (ms): Filters the underlying data (moving average)

opts.n = 500; %Number of steps

%Dwell times, raw for now
dws = exprnd(1, 1, opts.n); %Dwell time, set to exponential, 1s for now
rngpop = rand(1, opts.n); %Roll for which population each is from
acs = cumsum([0 opts.a]); %Set range for roll, jth dwell is from the ith exponential if acs(j) <= rngpop(j) < acs(j+1)
%Scale dwells
for i = 1:length(opts.a)
    ki = rngpop >= acs(i) & rngpop < acs(i+1);
    dws(ki) = dws(ki) / opts.k(i);
end

%Convert seconds to points
dws = ceil(dws*opts.Fs);

%Change to trace
in = cumsum([1 dws]);
me = 1:length(in)-1;
outraw = ind2tra(in, me);
%Add noise, filter underlying signal
out = randn(size(outraw))*noi + windowFilter(@mean, outraw, ceil(opts.resp/1000*opts.Fs), 1);