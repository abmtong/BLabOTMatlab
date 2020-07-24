function [x] = GheFilterAndDecimate(xd, num)
% This function filters and decimates the data. 
% For Example: Z = FilterAndDecimate(z,20)
% The script bins the z-data in bins of 20 pts each, then averages over these
% bins and outputs a smaller vector Z, with the bin averages
%
% Gheorghe Chistol, 09 Feb 2012

    x   = filter(ones(1, num), num, xd);
    ind = num:num:length(xd);
    x   = x(ind); 
end