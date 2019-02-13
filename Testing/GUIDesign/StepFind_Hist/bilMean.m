function outPt = bilMean(inData, domSigma, ranSigma)
%For use as @(x)bilMean(x, sig) with windowFilter
%To remove gaussianness in a dimension, make sig large

len = length(inData);
X = (1:len) - (floor((len+1)/2)); %for a normal window, this is -width:width

gauss = @(x,s) exp(-(x.^2)/(2*s^2));

domGauss = gauss(X,domSigma); 
ranGauss = gauss(inData-inData(X==0),ranSigma);
F = ranGauss.*domGauss;
outPt = sum(F.*inData)/sum(F);