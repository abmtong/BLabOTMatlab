function out = dmotor(axorob, inOpts)
%Draws a motor [5 orbs] in a given state
%Indexing is SSU first, then the rest 4
n=5;
px = 200;

opts.dht = [0 0 0 0 0]; %Relative heights of motor subunits
opts.alpha = [.5 1 1 .5 .5]; %Alpha channel
opts.cols = [1 1 1 1 1]; %Colors, for colormap
opts.dims= [.5 1 .5]; %Dimensions of motor in XYZ of SSU (which is in +x dir.)
opts.pos = [0 0 0]; %Center position
opts.sphsz = .55; %Size of sphere at junction
opts.r = 1.5; %Radius of motor pentagon (= side length), nm

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Create a rod, to be the motor
% [sx, sy, sz] = sphere(px);
[sz, sx, sy] = pill(px, 1); %pill along y
%Scale to dimensions
sx = sx * opts.dims(1);
sy = sy * opts.dims(2);
sz = sz * opts.dims(3);
sc = ones(size(sx));
% sc = reshape(1:numel(sx),size(sx));

%Crete a sphere, to be the joint
[tx, ty, tz] = sphere(px);
tx = tx * opts.sphsz;
ty = ty * opts.sphsz;
tz = tz * opts.sphsz;
tc = ones(size(tx));

%Translate/rotate/resize this sphere to make the motor
for i = 1:n
    %Get fresh sphere
    x = sx;
    y = sy;
    z = sz;
    %Get angle, in radians
    th = -2*pi/n * (i-1);
    %Rotate along x if hinge is open
    thz = -atan(opts.dht(i)/2*opts.r);
    [y,z] = rot2d(y,z,thz);
    %Translate to SSU position, say this is along +x
    x = x + opts.r;
    %Rotate along z by theta
    [x, y] = rot2d(x, y, th);
    %Translate along z
    z = z + sum(opts.dht(1:i-1))+opts.dht(i)/2;
    %Place orb at joint
    xa = opts.r;
    ya = opts.r*tan(36/180*pi);
    za = sum(opts.dht(1:i-1));% + opts.dht(i)/2 ;
    [xa, ya] = rot2d(xa, ya, th);
    %Plot / update: plot if axis passed
    if isa(axorob(1), 'matlab.graphics.axis.Axes')
        out(i) = surf(axorob,x,y,z,sc*opts.cols(i),'EdgeColor', 'none', 'FaceAlpha', opts.alpha(i)); %#ok<*AGROW>
        out(i+n) = surf(axorob, tx+xa, ty+ya, tz+za, tc * opts.cols(i), 'EdgeColor', 'none');
    else%Update if graphics array passed
        axorob(i).XData = x;
        axorob(i).YData = y;
        axorob(i).ZData = z;
        axorob(i).CData = sc*opts.cols(i);
        axorob(i).FaceAlpha = opts.alpha(i);
        axorob(i+n).XData = tx+xa;
        axorob(i+n).YData = ty+ya;
        axorob(i+n).ZData = tz+za;
        axorob(i+n).CData = tc*opts.cols(i);
        out = axorob;
    end
end












