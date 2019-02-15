function [xx, yy, zz] = cone(r)
%Returns a cone of radius r (default 1), unit height, along z
%try [xx yy zz]= cone; figure, surface(xx, yy, zz)

if nargin < 1
    r = 1;
end
res = 200;

[xx, yy] = meshgrid(linspace(-r, r, res));
zz = sqrt(xx.^2 + yy.^2) / r;

zz(zz > 1) = NaN;