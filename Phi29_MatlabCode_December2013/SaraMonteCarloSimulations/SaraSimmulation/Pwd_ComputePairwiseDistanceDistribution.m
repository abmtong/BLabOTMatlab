function [number, distance] = Pwd_ComputePairwiseDistanceDistribution(ContourData, HistogramBins)
% This function calculates the pairwise distance difference distribution
% using a double fourier transform for speed. Read more on Wikipedia
% http://en.wikipedia.org/wiki/Autocorrelation and the Steve Block article
% "Analysis of High Resolution Recordings of Motor Movement" in the
% Biophysical Journal, Volume 68, April 1995
%
% USE: [number, distance] = Pwd_ComputePairwiseDistanceDistribution(ContourData, HistogramBins)
%
% Gheorghe Chistol, 25 May 2012

%First of all bin the Contour Data in a histogram fashion
[n,d] = hist(ContourData,HistogramBins);

binsize = mean(diff(d));

np = abs(fft(n)).^2;
pwd = real(ifft(np)); %inverse FFT 

number = pwd(1:round(length(pwd)/2));
distance = (0:(length(number)-1))*binsize;
