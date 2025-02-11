function [outp, outx, outsd, outn] = nhistc(y, binsz, wgt)
%Calculate normalized histogram with integer-multiple bin limits
% A wrapper for the built-in @histcounts for speed
% For weighted and/or n-dimensional histogram binning, use @nhistc2

%Ignore NaN and inf
len = length(y);
y(isnan(y) | isinf(y)) = [];
if length(y) ~= len
    warning('Some Inf/NaN values ignored in @nhistc')
end
if nargin < 3
    wgt = ones(size(y));
end

if ~~isempty(y)
    outx = [];
    outp = [];
    outsd = [];
    outn = [];
    return
end

if nargin < 2
    binsz = 2*iqr(y)*numel(y)^(-1/3); %F-D rule of thumb
end

%Make bins, define as integer multiples of binsz
bins = binsz * ( floor(min(y)/binsz):ceil(max(y)/binsz));
%Make sure there's at least two bins [will be fewer if all y's equal]
if numel(bins) == 1
    bins = bins + [0 binsz];
end

outx = bins(1:end-1)+binsz/2;

%Without weights / equal weights
if length(unique(wgt)) == 1
    outn = histcounts(y, bins);
else
    %To handle weights, use @discretize
    dc = discretize(y, bins);
    outn = arrayfun(@(x) sum( wgt( dc == x ) ), 1:length(outx));
end

%Calculate p and sd from n
outp = outn / sum(outn) / binsz; %Integrate to normalize the area
outsd = sqrt(outn) / sum(outn) / binsz; %SD ~ sqrt(n), scale it like p was







