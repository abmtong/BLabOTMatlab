function [out, edges] = geofilter(dat, base)
%Filter with scaling filter factor

if nargin < 2
    base = 1.01;
end

%Pts per bin are round( base .^ (0:n)) )
len = length(dat);
maxn = floor( log(len) / log(base) );

wids = round( base.^(0:maxn) );
edges = cumsum(wids);

maxi = find(edges > len, 1, 'first');
edges = [edges(1:maxi-1) len+1];

nout = length(edges)-1;
out = zeros(1, nout);
for i = 1:nout
    out(i) = mean(dat( edges(i):edges(i+1)-1 ));
end