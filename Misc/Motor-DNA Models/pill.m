function [outx, outy, outz] = pill(n, r)
%Outputs the unit 'pill' (hemisphere-cylinder-hemisphere), along z
%r is the length of the cylinder with the spheres of unit length
%n is the number of pts. in the sphere, like @sphere



%hemispheres
[x, y, z] = sphere(n);

xl = x(1:end/2+.5,:);
yl = y(1:end/2+.5,:);
zl = z(1:end/2+.5,:);

xu = xl;
yu = yl;
zu = -zl + r/2;
zl = zl -r/2;

outx = [xl; flipud(xu)];
outy = [yl; flipud(yu)];
outz = [zl; flipud(zu)];


%hemisphere 2 is hemishpere 1 but reflected along z


%cylinder in-between


