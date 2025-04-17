function out = lensface(pos, r, wid)
%Create a lens face at a given position with radius r and width wid
% eg make a plano-convex lens with two lensFaces with the same pos, one r zero


nn = 1e4;

%Shortcut the flat case
if isinf(r) || r == 0
    %Plot
    yy = linspace(pos(2)-wid/2, pos(2)+wid/2, nn+1);
    out = plot(pos(1)*ones(1,nn+1), yy);
    return
end
%Solve for how far away the circle center is
dx = sqrt(r^2-(wid/2)^2);

%Get the angle of the arc
th0 = asin(wid/2/r);

% %Handle sign of r: + = curved to the right
% dx = -dx * sign(r);

%Create theta range
th = linspace( -th0, th0, nn+1);
%Create x,y range
xx = abs(r)*cos(th);
yy = abs(r)*sin(th);
%Shift xx to proper place
xx = (xx - dx) * sign(r) + pos(1);

%Plot
out = plot(xx, yy);
end