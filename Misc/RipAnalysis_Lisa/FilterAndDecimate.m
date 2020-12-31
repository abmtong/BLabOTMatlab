function x = FilterAndDecimate(Data, FilterFactor)
% This function filters and decimates the data. 
% For Example: Z = FilterAndDecimate(z,20)
% The script bins the z-data in bins of 20 pts each, then averages over these
% bins and outputs a smaller vector Z, with the bin averages
%
% Gheorghe Chistol, 26 Sep 2011

x   = filter(ones(1, FilterFactor), FilterFactor, Data);
ind = FilterFactor:FilterFactor:length(Data);
x   = x(ind); 
