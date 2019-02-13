function plotLine()
[x, y] = ginput(2);
dx = abs(diff(x));
dy = abs(diff(y));

line(x,y)
text(x(end),y(end),sprintf('(dx,dy,m) = (%0.2f, %0.2f, %0.2f)\n',dx,dy,dy/dx))