function [out, outraw] = simp29trace(noi, inOpts)
%Generates a p29-like data

if nargin < 1
    noi = 5;
end

%Trace options
opts.busz = 10; %Burst size, bp
opts.ssz = 2.5; %Step size, bp
opts.tdw = 60; %Dwell length, ms. Gamma-distributed, shape defined below
opts.dwk = 5; %Dwell shape (Gamma shape factor)
opts.tbu = 5; %Burst length, ms. Three per cycle (for four steps). Single-exponential
opts.Fs = 2.5e3; %FSamp
opts.resp = 10; %Response time (ms): Filters the underlying data (moving average)

opts.n = 100; %Number of bursts

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Reinterpret step size and burst size
nstep = ceil(opts.busz/opts.ssz);
ssz = [opts.ssz * ones(1,nstep-1) opts.busz-opts.ssz*(nstep-1)];


%Generate dwells
dws = sum( exprnd( opts.tdw/opts.dwk, opts.dwk, opts.n ), 1);
dwend = exprnd(opts.tdw/opts.dwk); %Generate one final dwell
%Generate bursts
bus = exprnd(opts.tbu, length(ssz)-1, opts.n);

%Concatenate dwells and bursts, reshape
ts = [dws; bus];
ts = [ts(:); dwend]'; %Dwell, burst, burst, burst, dwell, burst, burst, burst, ...

%Convert ms to pts
npts = ceil(ts / 1000 * opts.Fs); %Use ceil to have no zero-point steps
ind = cumsum([1 npts]); %Generate boundaries

%Generate step heights
y = cumsum([0 repmat( ssz, 1, opts.n )]);
%Reverse
y = opts.n*opts.busz - y;

%Compose step durations and sizes into a trace
outraw = ind2tra(ind, y);

%Add noise
out = windowFilter(@mean, outraw, ceil(opts.resp/1000*opts.Fs) , 1) + randn(size(outraw))*noi;
