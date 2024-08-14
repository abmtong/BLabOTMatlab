function [outy, outx, outn, outsd] = uniquebin(x,y)

%Bin by @unique
[outx, ~, ia] = unique(x);
outx = outx(:)';

outy = zeros(size(outx));
outn = zeros(size(outx));
outsd = zeros(size(outx));
for i = 1:length(outx)
    tmp = ia == i;
    outn(i) = sum(tmp);
    outy(i) = mean( y( tmp ) );
    outsd(i) = std(y(tmp));
end