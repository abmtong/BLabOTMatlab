function [xx yy zz] = spiral(npt, nt)
%returns a spiral with npt pts per turn and nt turns, with height 1 per turn
if nargin < 2
    nt = 10;
end
if nargin < 1
    npt = 100;
end
t =2*pi/npt*( 1:(npt*nt) );
xx = sin(t);
yy = cos(t);
zz = t/2/pi;