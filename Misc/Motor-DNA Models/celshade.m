function celshade(objs, inOpts)
opts.thr = .005;
if nargin >1
    opts = handleOpts(opts, inOpts);
end

%Hm, the thickness of the line depends on the curvature of the surface. Probably won't go with this.

%If objs not passed, act on all objects in gca
if nargin < 1
    ax = gca;
    objs = ax.Children;
    %Only act on surfaces
    ki = arrayfun(@(x)isa(x, 'matlab.graphics.chart.primitive.Surface'), objs);
    objs = objs(ki);
end

%Get camera normal
ax = objs(1).Parent;
n = ax.CameraTarget - ax.CameraPosition;
nhat = n / sum(n.^2);

%For every object...
for i = 1:length(objs)
    %Get surface normals
    [nx, ny, nz] = surfnorm(objs(i).XData, objs(i).YData, objs(i).ZData);
    %Dot camera normal into surface normal
    nxn = arrayfun(@(x,y,z) abs(sum([x y z].*nhat / sum([x y z].^2))),nx, ny, nz);
    %If this is small (< thr), set color index to 0
    objs(i).CData(nxn < opts.thr) = 0;
end
end