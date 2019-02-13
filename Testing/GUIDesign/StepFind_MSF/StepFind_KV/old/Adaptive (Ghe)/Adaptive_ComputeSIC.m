function [SIC DwellInd] = Adaptive_ComputeSIC(Y,StepInd,DwellInd,PenaltyFactor)
% Calculate the Schwartz Information Criterion score for the current step
% configuration. In order to make the whole thing faster and more
% efficient, save the Variance for each dwell in the DwellInd structure.
% This will help avoid unneccessary redundant calculations in the future.
%
% DwellInd(d).Start  - the index of the point where the t-th dwell starts
% DwellInd(d).Finish - the index of the point where the d-th dwell ends
% DwellInd(d).Mean   - the mean of the d-th dwell
% DwellInd(d).Var    - the variance for the d-th dwell
%
% USE: [SIC DwellInd] = KV_ComputeSIC(Y,StepInd,DwellInd)
%                     or
% USE: [SIC DwellInd] = KV_ComputeSIC(Y,StepInd,DwellInd,PenaltyFactor)
%
%                       PenaltyFactor is 1 by default, but can be increased to penalize overfitting
%                       PenaltyFactor = 3 or 4 is quite nice
%
% Gheorghe Chistol, 05 Apr 2011

if nargin==3
    PenaltyFactor = 1; %if the penalty factor wasn't specified
end

Var = 0;

for d=1:length(DwellInd)
    if isnan(DwellInd(d).Mean) %the mean and the variance are not defined for this dwell yet
        dwellY = Y(DwellInd(d).Start:DwellInd(d).Finish);
        DwellInd(d).Mean = mean(dwellY);
        DwellInd(d).Mean = sum(dwellY)/length(dwellY);
        DwellInd(d).Var  = sum((dwellY-DwellInd(d).Mean).^2);  
    end
    Var = Var+DwellInd(d).Var; %add the current variance to the total variance 
    % Note that the variance will only be calculated if it hasn't been
    % calculated before. This saves us a lot of time and computer cycles
end

n   = length(Y);
k   = length(StepInd);
SIC = PenaltyFactor*(k+2)*log(n)+n*log(Var/n);