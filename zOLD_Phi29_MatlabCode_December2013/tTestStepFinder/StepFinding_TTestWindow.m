function [t, sgn, sD] = StepFinding_TTestWindow(Data, WindowSize)
% Originally written by Jeff Moffitt, modified by Yann Chemla, modified by
% Gheorghe Chistol. This function calculates the t-test and sgn-value for
% the data using a given WindowSize
%
% USE: [t, sgn, sD] = StepFinding_TTestWindow(Data, WindowSize)
%
% Gheorghe Chistol, 15 March 2011

L = length(Data);

sgn = zeros(length(Data), 1);
t   = zeros(length(Data), 1);
sD  = zeros(length(Data), 1);

Data = [Data(1)*ones(1,WindowSize-1) Data Data(end)*ones(1,WindowSize-1)]; 

[M1,M2]   = meshgrid(0:WindowSize-1,1:L);
M         = M1+M2; 
leftSamp  = Data(M);
rightSamp = Data(M+WindowSize-1);
leftMean  = mean(leftSamp,2);
rightMean = mean(rightSamp,2);

sD  = sqrt((sum((leftSamp - meshgrid(leftMean',1:WindowSize)').^2,2) + sum((rightSamp - meshgrid(rightMean',1:WindowSize)').^2,2))/(WindowSize*(WindowSize-1)));
t   = (leftMean - rightMean)./sD;
sgn = betainc(2*(WindowSize-1)./(2*(WindowSize-1) + t.^2), WindowSize-1, 1/2);% Calculating t-test Significance value