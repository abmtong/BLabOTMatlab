function [outRT, outBins] = resTimeHist2(inY, inBinSz)
%Not gaussians

if nargin < 2
    inBinSz = 0.1;
end

%Nice Y-bins
nmin = floor(min(inY)/inBinSz);
nmax = ceil(max(inY)/inBinSz);

outBins = (nmin:nmax)*inBinSz;
outRT = zeros(1,length(outBins));

fcn = @(x,y)abs(x-y);
[~, ind] = min(bsxfun(fcn, inY, outBins'),[],1);
for i = 1:length(outBins)
    outRT(i) = sum(ind == i);
end