function [outx, outy, outz] = spiral(n, inOpts)
%Outputs a spiral along z with pixel density n

opts.ri = 0.1; %Radius of spiral tube
opts.r = 1; %Radius of spiral
opts.dz = 0.05; %granularity of spiral along z
opts.zrng = [-6.8 3.4]; %range of Zs to plot
opts.pitch = 3.4; %Pitch, nm

opts.dq = [0 -.2]; %Depth queue: modifier on each dimension

if nargin > 1
    opts = handleOpts(opts,inOpts);
end

%Generate z points
z = opts.zrng(1):opts.dz:opts.zrng(2);
hei = length(z);

%Generate ellipse in x/y
th = linspace(0,2*pi,n+1);
x = sin(th') * opts.ri;
y = cos(th') * opts.ri / cos( atan( opts.pitch / 2/pi/opts.r) );

%Generate sprial x/y
sth = -2*pi*z/opts.pitch;
sx = sin(sth)*opts.r;
sy = cos(sth)*opts.r;

%Spiral is this series of ellipses along z with the proper offsets, rotations
outx = zeros(n+1,hei);
outy = zeros(n+1,hei);
for i = 1:hei
    dq = 1 + sum(opts.dq .* (opts.r - [sx(i) sy(i)]));
    [tx, ty] = rot2d(x*dq,y*dq,-sth(i)+pi/2);
    outx(:,i) = tx + sx(i);
    outy(:,i) = ty + sy(i);
end
outz = repmat(z, [n+1, 1]);