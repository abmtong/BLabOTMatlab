% function 3dAligntester

%generate random spots
ndots = 100;

poses = randi(100, 3, ndots);

%generate rotation matricies
rotx = @(thx) [1 0 0; 0 cos(thx) -sin(thx); 0 sin(thx) cos(thx)];
roty = @(thy) [cos(thy) 0 sin(thy); 0 1 0; -sin(thy) 0 cos(thy)];
rotz = @(thz) [cos(thz) -sin(thz) 0; sin(thz) cos(thz) 0; 0 0 1];

rot = @(x) rotx(x(1)) * roty(x(2)) * rotz(x(3));

%and random angles
randths = randi(360, 3,1)/360*2*pi;
%and random noise
sd=.1;
randdpos = randn(3, ndots)*sd;
%and random translation
randtra = randi(10,3,1);

%generate generic translation/rotation fcn
trarot = @(x, dr, dth) bsxfun(@plus, rot(dth) * x, dr);

%perturb original system
pos2 = trarot(poses+randdpos, randtra, randths);

%generate guess/lb/ub
guess = zeros(6,1);
lb = [-inf -inf -inf -pi -pi -pi];
ub = [inf inf inf pi pi pi];
%generate obj fcn
fitfcn = @(x) trarot(pos2, [x(1) x(2) x(3)]', x(4:6)) - poses; 

%minimize with lsq
res = lsqnonlin(fitfcn, guess, lb, ub);

%compare result to actual
[res,[ randtra; randths]]

% figure, plot3(, 'o'), hold on, plot3(, 'o')


