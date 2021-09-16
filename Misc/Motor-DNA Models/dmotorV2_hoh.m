function out = dmotorV2_hoh(axorob, inOpts)
%Draws a motor [5 orbs] in a given state
%Indexing is SSU first, then the rest 4

%Need to change for HoH, since ring crack moves - dht not enough

n=5;
px = 200;

opts.ht = [0 0 0 0 0]; %Heights of motor subunits
opts.dht = [0 0 0 0 0]; %Degree of ring opening
% opts.alpha = [.75 .75 .75 .25 .25]; %Alpha channel. Back 3 sligtly transparent, front 2 mostly transp.
opts.alpha = .75* ones(1,5); %Alpha channel
opts.cols = [1 1 1 1 1]; %Colors, for colormap
opts.dims= [.5 1 .5]; %Dimensions of motor in XYZ of SSU (which is in +x dir.)
opts.pos = [0 0 0]; %Center position
opts.sphsz = .6; %Size of sphere at junction
opts.r = 1.5; %Radius of motor pentagon (perpendicular to edge), nm

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
    %Get fresh pill
    [sz, sx, sy] = pill(px, sqrt(opts.dht(i)^2 + (opts.r*2/tan(36/180*pi))^2)); %pill along y
    x = sx * opts.dims(1);
    y = sy * opts.dims(1);
    z = sz * opts.dims(1);
    %Get angle, in radians
    th = -2*pi/n * (i-1);
    %Rotate along x if hinge is open
    thz = -atan(opts.dht(i)/4*opts.r/tan(36/180*pi));
    [y,z] = rot2d(y,z,thz);
    %Translate to SSU position, say this is along +x
    x = x + opts.r;
    %Rotate along z by theta
    [x, y] = rot2d(x, y, th);
    %Translate along z
    z = z + opts.ht(i)+opts.dht(i)/2;
    %Place orb at joint
    xa = opts.r;
    ya = opts.r*tan(36/180*pi);
    za = opts.ht(i);% + opts.dht(i)/2 ;
    [xa, ya] = rot2d(xa, ya, th);
    %Translate
    x = x + opts.pos(1);
    y = y + opts.pos(2);
    z = z + opts.pos(3);
    xa = xa + opts.pos(1);
    ya = ya + opts.pos(2);
    za = za + opts.pos(3);
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












