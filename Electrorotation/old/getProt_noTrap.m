function out = getProt_noTrap(ineld, inOpts)

opts.dt = 0.1; %time which to remove 
opts.vthr = 1; %max velocity a segment can have
opts.rthr = 0.3; %max range a segment can have

Fs = ineld.inf.FramerateHz;

pts = round(opts.dt*Fs);

len = length(ineld.time);

t = (1:pts)/Fs;

%break rotations into r x pts matrix
r = reshape(rotlong(1:floor(len/twin)*twin), twin, []);
hei = size(r,2);
r = mat2cell(r, pts, ones(1,hei));

%Check slope, range of each
pf1s = cellfun(@(x) polyfit(t, x), r, 'Un', 0);
rngs = cellfun(@range, x);
slps = cellfun(@(x) x(1), pf1s);

%Pick "good" bits by range, velocity cutoff
ki = slps < opts.vthr & rngs < opts.rthr;

%Calculate autocorr.s