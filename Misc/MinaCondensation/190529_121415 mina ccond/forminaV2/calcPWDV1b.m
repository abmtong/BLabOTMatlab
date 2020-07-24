function [outPWD, outX] = calcPWDV1b( inY, binsize )
%Calculates the pairwise distribution of data inY
%Bins with binsize, then calculates PWD via FT
%Normalizes so PWD(1) = 1

if nargin < 2
    binsize = 0.2;
end

p = cdf(inY,binsize);
p = diff([0 p]); %first value of cdf is fine, = pdf(1)

% p = sgolaydiff(inY, {1 13});

% p = diff(diff(p));
% p = log(p);
% p = resTimeHist(inY,binsize);

%We can try to pad the end with 0s, uglifies
% p = [p zeros(1, length(p))];

%We can try to remove the flanking regions, helps?
% p = p( (1:length(p)) > length(p)/10 & (1:length(p)) < length(p)*9/10);

% p = normHist(inY, binsize);
% p = p(:,2)';

%regular V1b
% outPWD = real(ifft(abs(fft(p)).^2));
% outPWD = outPWD(1:floor(end/2)) / outPWD(1);

outPWD = acorr2(p);

outX = binsize*(0:length(outPWD)-1);