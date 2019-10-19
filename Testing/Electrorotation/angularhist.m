function [outp, outth, outraw, cen] = angularhist(inx, iny, thbin)

if nargin < 3
    thbin = 2; %deg per bin. output is rad, tho
end

%Find the center. Use outlier-independent range (99th to 1st percentile)
dprc = .5;
cen = [ mean(prctile(inx, [dprc 100-dprc]))  mean(prctile(iny, [dprc 100-dprc]))];
inx = inx - cen(1);
iny = iny - cen(2);

outraw = atan( iny ./ inx );
outraw = outraw + pi * (inx<0);
outraw = mod(outraw, 2*pi);

bdys = 0:thbin:360;
bdys = bdys / 180 * pi;
outp = histcounts(outraw, bdys);

outth = bdys(1:end-1) + thbin/360*pi;