function out = gcocrop(xx)
%Crops a plotted object (gets data from a given x-range), select with mouse cursor tool

ob = gco;

if nargin < 1
    %Get crop bars. Active plot should be the same one as gco...?
    xx = ginput(2);
end

xx = sort(xx);
%Get x/y vars
x = ob.XData;
y = ob.YData;
ki = x>xx(1) & x<xx(2);

out = y(ki);