function [outy, outx, outn] = whistc(y, wts, binsz)
%Histcounts but accepts weights. Uses @dicretize to bin at the speed of @histcounts

%Ignore NaN and inf
len = length(y);
y(isnan(y) | isinf(y)) = [];
if length(y) ~= len
    warning('Some Inf/NaN values ignored in @whistc')
end

if nargin < 3
    binsz = 2*iqr(y)*numel(y)^(-1/3); %F-D rule of thumb
end

if nargin < 2
    wts = ones(size(y));
end

bins = binsz * ( floor(min(y)/binsz):ceil(max(y)/binsz));

if length(bins) < 3
    warning('bad binsz in nhistc')
    outy = 0;
    outx = 0;
    outn = 0;
    return
end

%Use @discretize to determine which bin things fit into
yi = discretize(y, bins);

%And sum along yi indicies
nbin = length(bins)-1;
outy = zeros(1,nbin);
outn = zeros(1,nbin);
for i = 1:nbin
    ki = yi == i;
    outy(i) = sum(wts(ki))/binsz;
    outn(i) = sum(ki);
end

outx = bins(1:end-1)+binsz/2;