function [x, y, z] = starburst(n)

%Makes a unit starburst from... ?

% %Create from polar to cartesian
% phi = linspace(0,2*pi,n+1);
% psi = linspace(0,2*pi,n+1)';
% % rad = rand(n+1)/2+1;
% rad = 1+mod(1:(n+1)^2,2)/2;
% rad = reshape(rad,n+1,n+1);
% 
% [x, y, z] = sph2cart(repmat(phi, [n+1 1]), repmat(psi, [1 n+1]), rad);

%Maybe a good thing to start from is an augmented icosahedron (e.g. the Mathematica logo)
%
% phi = [-pi/2 repmat(-atan(.5), [1,5]) repmat(atan(.5), [1,5]) pi/2];
% psi = [0 (0:4)/5*2*pi (0:4)/5*2*pi+pi/10 0]';
% r = ones(12);
% 
% [x, y, z] = sph2cart(repmat(phi, [12 1]), repmat(psi, [1 12]), r);

phi = [-pi/2 -atan(.5) atan(.5) pi/2];
% phi = repmat(phi, [5 1]);
phi = phi(:)';
psi = [zeros(1,5) (0:9)/10*2*pi zeros(1,5)]';

psi = [ ...
0 0 2 2 4 4 6 6 8 8 0; ...
0 0 2 2 4 4 6 6 8 8 0;...
9 1 1 3 3 5 5 7 7 9 9 ;...
9 1 1 3 3 5 5 7 7 9 9];
psi = psi / 10 * 2 * pi;

phi = repmat(phi', [1 size(psi,2)]);

% [hh, ss] = meshgrid(phi, psi);
r = ones(size(psi));

% [x, y, z] = sph2cart(repmat(phi, [20 1]), repmat(psi, [1 20]), r);
% [x, y, z] = sph2cart(ss, hh, r);
[x, y, z] = sph2cart(psi, phi, r);


%Define points we want..
%Icosahedron is made of of these points...
unith = unique(phi + 1i*psi);
uphi = real(unith);
upsi = imag(unith);
r = ones(size(uphi));

[x, y, z] = sph2cart(upsi, uphi, r);

dt = delaunayTriangulation([x, y, z]);

figure, trisurf(dt.ConnectivityList, x, y, z);

%And triangulate them










