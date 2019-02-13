function nums = lcgn(n, in, a, c, m)

if nargin < 3
    a = 1664525;
end
if nargin < 4
    c = 1013904223;
end
if nargin < 5
    m = 2^32;
end

nums = zeros(1, n);
nums(1) = lcg(in, a, c, m);
for i = 2:n
    nums(i) = lcg(nums(i-1), a, c, m);
end