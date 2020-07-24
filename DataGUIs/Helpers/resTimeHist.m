function [outRT, outBins] = resTimeHist(inY, inBinSz, inWin, inDec)


if nargin < 4
    inDec = 1;
end

if nargin < 3
    inWin = 5;
end

if nargin < 2
    inBinSz = 0.1;
end

%Nice Y-bins
nmin = floor(min(inY)/inBinSz);
nmax = ceil(max(inY)/inBinSz);

outBins = (nmin:nmax)*inBinSz;

len = length(inY);

%gauss = @(mean, sd) exp(-(outBins - mean).^2/2/sd);

outRT = zeros(1,length(outBins));
for i = inDec:inDec:len
    ran = (i-inWin:i+inWin);
    ran(ran < 1 | ran > len) = [];
    %unnorm'd gaussian
    %outRT = outRT + gauss(inY(i), std(inY(ran)));
    
    %std
%     outRT = outRT + normpdf(outBins, inY(i), std(inY(ran)));
    %ste = std/rad(n)
    outRT = outRT + normpdf(outBins, inY(i), std(inY(ran))/sqrt(length(ran)));
end