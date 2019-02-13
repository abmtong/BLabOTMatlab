function NminList = CalculateNminConfInt(DwellTimes,Nsim)
% This functions calculates Nmin given a pool of DwellTimes
% Nsim  - number of simulation rounds using our data
%
% USE NminList = CalculateNminConfInt(DwellTimes,Nsim)
%
% Gheorghe Chistol, 9 Mar 2011

%Nmin=mean(DwellTimes)^2/(mean(DwellTimes.^2)-mean(DwellTimes)^2);

% Divide the data randomly in two subsets and calculate their Nmin to do a
% jack-knife control to estimate error

NminList = [];
for i=1:Nsim
    temp = rand(1,length(DwellTimes));
    Condition = temp>0.5;
    Subset1 = DwellTimes(Condition);
    Subset2 = DwellTimes(~Condition);
    Nmin1 = mean(Subset1)^2/(mean(Subset1.^2)-mean(Subset1)^2);
    Nmin2 = mean(Subset2)^2/(mean(Subset2.^2)-mean(Subset2)^2);
    NminList(end+1:end+2) = [Nmin1 Nmin2];
end