function plotLine(plotY)
if nargin < 1
    plotY = 0;
end
a = ginput(2);
if ~plotY
    x = a(:,1);
    line(x',a(1,2)*[1 1]);
    text(mean(x),a(1,2),num2str(x(2)-x(1)))
else
    y = a(:,2);
    line(a(1,1)*[1 1],y);
    text(a(1,1),mean(y),num2str(y(2)-y(1)))
end