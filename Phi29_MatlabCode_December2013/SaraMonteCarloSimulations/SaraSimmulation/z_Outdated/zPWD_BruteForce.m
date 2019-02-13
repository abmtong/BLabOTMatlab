function [N, D] = PWD_BruteForce(CropLength,BinPWD)
% Use the brute force method to calculate the periodicity
% This is useful in particular for small portions of a trace, where the
% traditional FFT approach has large artefacts
%
% Gheorghe Chistol, 09 May 2011

Distance = [];
for i=1:length(CropLength)-1
    temp = CropLength(i+1:end)-CropLength(i);
    Distance = [Distance temp];
end
Distance = abs(Distance); %we only care about the absolute value of the distance
Bins = 0+BinPWD/2:BinPWD:max(Distance);

[N D] = hist(Distance,Bins);