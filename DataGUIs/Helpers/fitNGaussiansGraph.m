function out = fitNGaussiansGraph(guessmean, onlypos)
if nargin<2
    onlypos = 0;
end
if nargin < 1
    guessmean = [2.5 5];
end
ax = gca;
x = ax.Children.XData;
y = ax.Children.YData;
if onlypos
    keepind = x>0;
    x = x(keepind);
    y = y(keepind);
end

tmp = fitNGaussians(x, y, guessmean);

if nargout
    out = tmp;
end