function [outoffax, outofftd] = tsoffset(intd, inax, binsz)
if nargin < 3
    binsz = .1;
end

%Get start, end of trap delta (to the binsz)
fmin = floor(min(intd / binsz))*binsz;
fmax = ceil (max(intd / binsz))*binsz;

outofftd = fmin:binsz:fmax;

%Bin with values centered around points
binshift = outofftd - binsz/2;

%Sum over bins. I do this very weirdly / inefficiently but nice to write
ccdf = arrayfun(@(x) sum(inax(intd > x)), binshift);
n = arrayfun(@(x) sum(intd > x), binshift);
%same as:
% for i = 1:len
%     cdf(i) = sum(inax(intd > binshift(i)));
% end
outoffax = [diff(ccdf)./ diff(n),  ccdf(end)/n(end)];