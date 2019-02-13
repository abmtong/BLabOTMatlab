function [x] = BurstSize_FilterAndDecimate(xd, num)
% This function filters and decimates the data. 
% For Example: Z = FilterAndDecimate(z,20)
% The script bins the z-data in bins of 20 pts each, then averages over these
% bins and outputs a smaller vector Z, with the bin averages
%
% Gheorghe Chistol, 09 Feb 2012

    x   = filter(ones(1, num), num, xd);
    x   = x(num:end); 
end