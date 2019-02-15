function [xx, yy] = hexagon()
%outputs the (x,y) pairs to plot a hexagon centered at (0,0)
% with vertex (1,0) that is inscribed in the unit circle

angs = ([0:5 0]) * pi/3;

xx = cos(angs);
yy = sin(angs);