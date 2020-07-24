function [outY, outX] = cdf(inData, binsz)
if nargin<2
    binsz = 0.1;
end

miny = floor(min(inData/binsz))*binsz;
maxy = ceil(max(inData/binsz))*binsz;
outX = miny:binsz:maxy;

outY = arrayfun(@(x) sum(inData < x+binsz/2), outX);
