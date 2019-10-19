function [outp, outx, outsd, outn] = nhistc(y, binsz)
%Calculate normalized histogram with integer-multiple bin limits
%nhistc = "NormalizedHISTCounts"

%Ignore NaN and inf
len = length(y);
y(isnan(y) | isinf(y)) = [];
if length(y) ~= len
    warning('Some Inf/NaN values ignored in @nhistc')
end

if nargin < 2
    binsz = 2*iqr(y)*numel(y)^(-1/3); %F-D rule of thumb
end

bins = binsz * ( floor(min(y)/binsz):ceil(max(y)/binsz));

if length(bins) < 3
    warning('bad binsz')
    outp = 0;
    outx = 0;
    outsd = 0;
    outn = 0;
    return
end

outx = bins(1:end-1)+binsz/2;
outn = histcounts(y, bins);
outp = outn / sum(outn) / binsz; %Integrate to normalize the area
outsd = sqrt(outn) / sum(outn) / binsz; %SD ~ sqrt(n), scale it like p was