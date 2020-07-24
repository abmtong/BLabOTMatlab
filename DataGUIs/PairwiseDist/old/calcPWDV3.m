function [outPWD, outX] = calcPWDV3( inY, binsize, win )
%Calculates the pairwise distribution of data inY
%Normalizes so PWD(1) = 1

if nargin < 3
    win = 5;
end
if nargin < 2
    binsize = 0.05;
end

p = resTimeHist(inY, binsize, win);
% p = resTimeHist(inY);

% p = diff(p); %deriv
% p = -diff(diff(p)); %2nd deriv
% p = diff(diff(diff(p)));

% p(p<0)=0;

%these don't change much
% p = p + min(p)+100; %rezero, recenter
% p = p / max(p);

outPWD = real(ifft(abs(fft(p)).^2));
outPWD = outPWD(1:floor(end/2)) / outPWD(1);

% outPWD = acorr2(p);
outX = binsize*(0:length(outPWD)-1);
