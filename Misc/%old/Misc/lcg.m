function out = lcg( in, a, c, m )
%lcg RNG, what the timeshareds use for phase randomization

if nargin < 2
    a = 1664525;
end
if nargin < 3
    c = 1013904223;
end
if nargin < 4
    m = 2^32;
end

out = mod(in * a + c, m);