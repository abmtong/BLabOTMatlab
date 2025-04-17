function out = lensDemo()
%A demonstration of conjugate planes and why it is important
% A mirror and a telescope imaging onto a target (objective entry or QPD)

%Let's... solve equations to plot how a plano-convex lens would go?

%Lensmaker's formula: P = (n_lens-n_0)/n_0 * (1/r1-1/r2), n is the refractive index of lens/medium, r is the radius of the surfaces of the sides of the lens
% Let's use nlens = 1.5167, the n of Thorlabs N-BK7 lenses, and n0=air=1
% So P = (0.5167)/R for a plano-convex (r2 = inf)
% For a 50/100cm lens, then we can calulate R = f/0.5167?

%Focal length, cm
f1=5;
f2=10;

n = 1.5167;
r1 = f1/(n-1);
r2 = f2/(n-1);

%Assemble lenses. Hardcode as going off of a mirror, then lens 1, lens 2

%Basically we need the points of contact... start at (0,0), then lens1 surface 1, lens 1 surface 2, 
% Maybe write a helper that does the inter-lens calcs

%Because that's not that simple... 
% Maybe we just do a 'coarse grained' thing where we do simple segment intersections and do math off that
%Basically, divide the lens face into 1e4 segments, find which one the ray intersects, then diffract. Then we just need snells' law

figure, hold on
nn = 1e4;

%Create lens face 1a
lf(1) = lensface([10 0], -r1, 1, nn);
%Create lens face 1b
lf(2) = lensface([10 0], 0, 1, nn);
%Lens face 2a
lf(3) = lensface([25 0], 0, 1, nn);
%Lens face 2b
lf(4) = lensface([25 0], r2, 1, nn);


%Current ray details
pos = [0 0];
ang = 0; %Angle, 0 = to the right

len = length(lf);
for i = 1:len
    %Find intersect
    
    %Reflect
    
    %Plot segment
    
    
end




end

function out = doIntersect(x1,x2,y1,y2,xx,yy)
%Find intersect of 


end


function out = lensface(pos, r, wid, nseg)
%Create a lens face at a given position with radius r and width wid
% eg make a plano-convex lens with two lensFaces with the same pos, one r zero

%Shortcut the flat case
if isinf(r) || r == 0
    %Plot
    yy = linspace(pos(2)-wid/2, pos(2)+wid/2, nseg+1);
    out = plot(pos(1)*ones(1,nseg+1), yy);
    return
end
%Solve for how far away the circle center is
dx = sqrt(r^2-(wid/2)^2);

%Get the angle of the arc
th0 = asin(wid/2/r);

% %Handle sign of r: + = curved to the right
% dx = -dx * sign(r);

%Create theta range
th = linspace( -th0, th0, nseg+1);
%Create x,y range
xx = abs(r)*cos(th);
yy = abs(r)*sin(th);
%Shift xx to proper place
xx = (xx - dx) * sign(r) + pos(1);

%Plot
out = plot(xx, yy);
end
