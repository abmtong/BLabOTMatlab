function [outx, outy] = tocdf(dat, ccdf)

if nargin < 2
    ccdf = 0;
end

len = length(dat);

outx = sort(dat, 'ascend');
if ccdf %Complementary CDF
    outy = (len:-1:1) / len;
else %Normal CDF
    outy = (1:len) / len;
end
