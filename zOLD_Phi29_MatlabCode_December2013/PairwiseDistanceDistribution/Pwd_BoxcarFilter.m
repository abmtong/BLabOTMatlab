function x = Pwd_BoxcarFilter(xd, num)
% This function filters but doesn't decimates the data. 
% For Example: x = Pwd_BoxcarFilter(xd, num)
%
% Gheorghe Chistol, 25 May 2012

x = filter(ones(1, num), num, xd);
if length(x)>num-1
    x(1:num-1) = []; %to make sure the start of the vector is well-behaved
end