function out = coprimes(n, nmax)

if nargin < 2
    nmax = n;
end
if nmax > 1e6
    error('nmax must be <1e6')
end

out = 1:nmax;
gcfs = arrayfun(@(x) gcd(n,x), out);

out = out(gcfs == 1);