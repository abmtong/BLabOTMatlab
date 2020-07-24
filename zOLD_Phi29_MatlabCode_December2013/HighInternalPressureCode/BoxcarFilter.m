function [x] = BoxcarFilter(xd, num)
% This function filters but doesn't decimates the data. 
% For Example: Z = [x] = BoxcarFilter(z,20)
%
% Gheorghe Chistol, 27 April 2011

x          = filter(ones(1, num), num, xd);
if length(x)>num-1
    x(1:num-1) = []; %to make sure the start of the vector is well-behaved
end