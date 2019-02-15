function [xx, yy, zz] = hyperboloid(r, r0)
%Returns a hyperboloid of outer radius r (radius at heihgt 1, default 1), unit height, internal relative radius r0 along xy
%try [xx yy zz]= cone; figure, surface(xx, yy, zz), surface(xx,yy,-zz)

if nargin < 1
    r = 1;
end

if nargin < 2
    r0 = .5;
end

res = 200;

[xx, yy] = meshgrid(linspace(-r, r, res));
zz = sqrt(xx.^2 + yy.^2 - (r*r0)^2) / r ;
%center values will evaluate to complex - remove
zz(~isreal(zz)) = NaN;
zz = real(zz);
%scale zz, since zz at (r, 0) won't hit 1
zz = zz ./ sqrt(1-r0^2);
%chop top of cone
zz(zz > 1) = NaN;
