function Nmin=MonteCarlo_CalculateNmin(DwellTimes)
% This functions calculates Nmin given a pool of DwellTimes
%
% USE Nmin=MonteCarlo_CalculateNmin(DwellTimes)
%
% Gheorghe Chistol, 9 Mar 2011

Nmin=mean(DwellTimes)^2/(mean(DwellTimes.^2)-mean(DwellTimes)^2);
