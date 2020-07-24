function [t, sgn, sD] = z_FindBursts_TTestWindow(Data, WindowSize)
% Originally written by Jeff Moffitt, modified by Yann Chemla, modified by
% Gheorghe Chistol. This function calculates the t-test and sgn-value for
% the data using a given WindowSize
%
% USE: [t, sgn, sD] = StepFinding_TTestWindow(Data, WindowSize)
%
% Gheorghe Chistol, 15 March 2011

%notes below by Alex
L = length(Data);

sgn = zeros(length(Data), 1);
t   = zeros(length(Data), 1);
sD  = zeros(length(Data), 1);

Data = [Data(1)*ones(1,WindowSize-1) Data Data(end)*ones(1,WindowSize-1)]; 

[M1,M2]   = meshgrid(0:WindowSize-1,1:L);
M         = M1+M2; 
%equivalent to >>M = bsxfun(@plus, 0:WindowSize-1, (1:L)'); %gets the indicies of WindowSize points to the left of the test point, add WindowSize-1 to get the pts to the right of the test pt.

leftSamp  = Data(M);
rightSamp = Data(M+WindowSize-1);
leftMean  = mean(leftSamp,2);
rightMean = mean(rightSamp,2);

%equiv to >>sD = sqrt(( sum(bsxfun(@minus, leftSamp, leftMean').^2 ,2) + sum( bsxfun(@minus, rightSamp, rightMean').^2, 2) )/ WindowSize/(WindowSize-1));
%why does he divide by WinSz*(WinSz-1) ? it doesn't really matter since winSz is constant but that seems wrong?

sD  = sqrt((sum((leftSamp - meshgrid(leftMean',1:WindowSize)').^2,2) + sum((rightSamp - meshgrid(rightMean',1:WindowSize)').^2,2))/(WindowSize*(WindowSize-1)));

%standard t=obs1-obs2 /sd
t   = (leftMean - rightMean)./sD;
sgn = betainc(2*(WindowSize-1)./(2*(WindowSize-1) + t.^2), WindowSize-1, 1/2);% Calculating t-test Significance value