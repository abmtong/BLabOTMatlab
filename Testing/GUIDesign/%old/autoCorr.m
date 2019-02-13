function outCorr  = autoCorr(inData)
outCorr = ifft(abs(fft(inData)).^2);
outCorr = outCorr(1:round(length(inData)/2));