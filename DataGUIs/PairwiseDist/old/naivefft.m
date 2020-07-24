function [outfft, outf] = naivefft(inX, inY)
maxF = 100;
dF = 0.1;
outf = 0:dF:maxF;
len = length(outf);
outfft = zeros(1, len);
for i = 1:len;
    outfft(i) = sum(inY .* cos(2*pi / outf(i) * inX));
end