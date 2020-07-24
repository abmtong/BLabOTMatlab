function [outY, outX] = cdf(inData, binsz)
%...it's easier to just take the pdf, actually
%Keep this here for compatability, but replaced with @histcounts that calc.s a pdf and cumsums it to cdf
%Different from @nhistc - nhistc centers on half-integer mult.s of binsz, this on integer binsz

if nargin<2
    binsz = 0.1;
end

miny = floor(min(inData/binsz))*binsz;
maxy = ceil(max(inData/binsz))*binsz;
outX = miny:binsz:maxy;

outY = histcounts(inData, [outX-binsz/2 outX(end)+binsz/2]);
outY = cumsum(outY);

%Old way, slower [this is like N^2 while above is N]
% outY = arrayfun(@(x) sum(inData < x+binsz/2), outX);

%Old way another
% dind = round(miny(1)/binsz);
% int = round(inData/ binsz)- dind + 1;
% outY = zeros(size(outX));
% for i = 1:length(inData)
%     outY(int(i)) = outY(int(i)) + 1;
% end
% outY = cumsum(outY);

