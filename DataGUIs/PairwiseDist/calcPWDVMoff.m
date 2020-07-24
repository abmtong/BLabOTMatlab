function [out, x] = calcPWDVMoff( inY, filpre, binszn )
%Calculates the pairwise distribution of data inY
%Bins with binsize, then calculates PWD via FT
%Normalizes so PWD(1) = 1

if nargin < 2
    filpre = 5;
end

if nargin < 3
    binszn = [0.05 200];
end
%Filter first
inY = windowFilter(@mean, inY, filpre, 1);
%Take every pair of pts and take their difference. Only take upper triangle (a(i,j) = -a(j,i), so redundant)

mat = triu(bsxfun(@minus, inY, inY'));
x = eps:binszn(1):binszn(1)*binszn(2);
mat = abs(mat(:));
out = hist(mat, x);
x = (x(1:end-1) + x(2:end) )/2;
% figure, histogram(mat, x)