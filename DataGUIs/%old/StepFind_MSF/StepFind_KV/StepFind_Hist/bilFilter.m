function outData = bilFilter(inData, inWidth, domSigma, ranSigma)
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