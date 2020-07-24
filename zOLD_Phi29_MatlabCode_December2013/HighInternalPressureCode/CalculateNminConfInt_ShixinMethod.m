function NminList = CalculateNminConfInt_ShixinMethod(DwellTimes,Nsim)
% This functions calculates Nmin given a pool of DwellTimes
% Nsim  - number of simulation rounds using our data
% given a sample of DwellTimes with N points, draw a point at random N
% times from this DwellTimes data pool and calculate Nmin. it's okay if the
% same value gets drawn twice
%
% USE NminList = CalculateNminConfInt(DwellTimes,Nsim)
%
% Gheorghe Chistol, 17 June 2011

%Nmin=mean(DwellTimes)^2/(mean(DwellTimes.^2)-mean(DwellTimes)^2);

% Divide the data randomly in two subsets and calculate their Nmin to do a
% jack-knife control to estimate error

NminList = [];
for i=1:Nsim
    CurrSample = randsample(DwellTimes,length(DwellTimes),1); %draw, drawing the same value twice is ok
    NminList(end+1) = mean(CurrSample)^2/(mean(CurrSample^2)-mean(CurrSample)^2);
end