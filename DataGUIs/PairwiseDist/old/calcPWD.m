function [outPWD, outX] = calcPWD( inY, binsize )
%Calculates the pairwise distribution of data inY
%Bins with binsize, then calculates PWD via FT
%Normalizes so PWD(1) = 1

if nargin < 2
    binsize = 0.2;
end
p = normHist(inY,binsize);
outPWD = real(ifft(abs(fft(p(:,2))).^2));
outPWD = outPWD(1:floor(end/2)) / outPWD(1);
outX = binsize*(0:length(outPWD)-1);