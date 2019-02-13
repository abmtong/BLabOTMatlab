function outData = bilFilter(inData, inWidth, domSigma, ranSigma)
%Bilaterally filters an input data. Bilateral = increased weighting for near points and near values
%dom[ain]Sigma controls weighting in x dimension, unit pts
%ran[ge]Sigma controls weighting in y dimension, unit same as inData
%inWidth says how many pts to consider around inData
%Could be good for SNR >> 1?

if nargin < 2
    inWidth = 11;
end
if nargin < 3
    domSigma = floor(inWidth/2)+1;
end
if nargin < 4
    ranSigma = estimateNoise(inData);
end

X = -inWidth:inWidth;
gauss = @(x,s) exp(-(x.^2)/(2*s^2));

%Domain gaussian, always the same
domGauss = gauss(X,domSigma); 

len = length(inData);
outData = zeros(1,len-2*inWidth);
for i = 1+inWidth:len-inWidth
    % Take neighborhood about ith point
    snip = inData(i-inWidth:i+inWidth);
    % Range gaussian
    ranGauss = gauss(snip-inData(i),ranSigma);
    
    %Bilateral filter = domain * range parts
    F = ranGauss.*domGauss;
    outData(i-inWidth) = sum(F.*snip)/sum(F);
end
end