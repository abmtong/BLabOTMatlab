function [out, tra] = testtrRuler(scl, off)

%Generates a test trace that follows ruler repeats


%Futz it up a bit
if nargin < 1
    scl = 1.03; %Error in scale, say 3%
end
if nargin < 2
    off = 100; %Error in position, say 100bp
end

%Trace props (mean dwell, noise)
mdw = 30; %Pts
noi = 3; %bp
dwmul = 10; %Pauses are this many times longer

%Pause struct
pau = struct('a', 83, 'b', 108, 'c', 141, 'd', 168, 'h', 236);
relstr = [1 1.5 1 1.5 1.5];
nnt = 239;
nrep = 8;

%Generate regular dwells
dwnpad = 20; %Pad with 20 on each side + all of off
ndws = nnt*nrep + abs(off) + dwnpad*2; %Generate regular dwells, pad dwells, and offset dwells
dws = ceil(exprnd(mdw, 1, ndws));

%Replace the pause site dwells with longer ones
fns = fieldnames(pau);
for i = 1:length(fns)
    fn = fns{i};
    in = pau.(fn);
    dws( dwnpad + in + nnt*(0:nrep-1) + max(0,off) ) = ceil(exprnd(mdw*dwmul, 1, nrep)*relstr(i));
end

%Generate this staircase
ind = [1 cumsum(dws)];
mea = (1:length(dws))-dwnpad - max(0,-off);
tra = ind2tra(ind,mea);

%Scale and add noise
out = tra * scl + randn(1,length(tra))*noi;