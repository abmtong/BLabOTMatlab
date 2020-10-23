function cdnarr = num2cdn(num, nc)
%Takes the state number i and converts it to the codon nc-tuplet [a, b, c, ...] where each value is ATGC=1234

if nargin < 2
    nc = 4;
end

%Change from index-1 to index-0
num = num - 1;

%Convert to base-4, knowing there is max 3 digits (simple quotient + remainder)
cdnarr = zeros(1,nc);
for i = 1:nc
    pwr = 4 ^(nc-i);
    cdnarr(i) = floor(num/pwr);
    num = num-cdnarr(i)*pwr;
end

%Change from index-0 to index-1
cdnarr = cdnarr + 1;