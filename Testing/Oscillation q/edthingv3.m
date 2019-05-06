function edthingv3(inx,iny, binsz)
%now count crossings of the entire arrow

tic
if nargin < 1
    inx = repmat([ones(1,100)*1, zeros(1,100)], 1, 50e3);
    iny = repmat([-ones(1,100)*1, zeros(1,100)], 1, 50e3);
    inx = [inx zeros(1,10)];
    iny = [zeros(1,10) iny];
    inx = smooth(inx, 5);
    iny = smooth(iny, 5);
    inx = inx + randn(size(inx)); %100kHz * 100s = 1e7 pts
    iny = iny + randn(size(inx)); %100kHz * 100s = 1e7 pts
    tx = inx;
    ty = iny;
    inx = tx + ty;
    iny = tx - ty;
end
if nargin < 3
%     binsz = 0.5e-1;
    binsz = range(inx) / 50;
end
%get diff coords
dinx = diff(inx);
diny = diff(iny);
dinr = sqrt(dinx.^2 + diny.^2);
dinxh = dinx ./ dinr;
dinyh = diny ./ dinr;

%shift indata to natural coords
inxb = floor(inx / binsz);
inyb = floor(iny / binsz);

xoff = min(inxb);
yoff = min(inyb);

inxb = inxb - xoff + 1;
inyb = inyb - yoff + 1;

inx = inx/binsz - xoff + 1;
iny = iny/binsz - yoff + 1;

xr = max(inxb);
yr = max(inyb);

len = length(inxb);
outc = zeros(xr,yr);
outdx = zeros(xr,yr);
outdy = zeros(xr,yr);


for i = 1:len-1
    outc(inxb(i), inyb(i)) = outc(inxb(i), inyb(i)) + 1;
    %now, 'plot the arrow' from i to i+1 and find border crossings
    %parameterize x=mt+x0 , y = nt+y0 and solve for integers (integers are borders)
    xs = sort([inx(i) inx(i+1)]);
    ys = sort([iny(i) iny(i+1)]);
    mx = dinx(i);
    my = diny(i);
    %find crossings
    dx = ceil(xs(1)):floor(xs(2));
    dy = ceil(ys(1)):floor(ys(2));
    dxl = length(dx);
    dyl = length(dy);
    for j = 1:dxl %moving along x
        %find the y value this crossing corresponds to
        t = (dx(j) - inx(i)) / mx; %t is in [0, 1]
        yy = floor(my * t + iny(i));
        s=sign(mx);
        %and then add to the relevant counters
        outdx(dx(j), yy)   = outdx(dx(j), yy) + s;
        outdx(dx(j)-1, yy) = outdx(dx(j)-1, yy) + s;
    end
    for j = 1:dyl %moving along y
        %find the y value this crossing corresponds to
        t = (dy(j) - iny(i)) / my; %t is in [0, 1]
        xx = floor(mx * t + inx(i));
        s=sign(my);
        %and then add to the relevant counters
        outdy(xx, dy(j))   = outdy(xx, dy(j)) + s;
        outdy(xx, dy(j)-1) = outdy(xx, dy(j)-1) + s;
    end
    
    
    outdx(inxb(i), inyb(i)) = outdx(inxb(i), inyb(i)) + dinxh(i);
    outdy(inxb(i), inyb(i)) = outdy(inxb(i), inyb(i)) + dinyh(i);
    if mod(i,1e6) == 0
        fprintf('|');
    end
end


[xx, yy] = meshgrid(1:xr, 1:yr);
xx = (xx'+xoff-1)*binsz;
yy = (yy'+yoff-1)*binsz;

%should probably normalize d by n, e.g. d = d ./ n

%norm d so largest arrow is length 1
mxd = sqrt( max( max( outdx .^2 + outdy.^2 ) ) );
outdx = outdx / mxd;
outdy = outdy / mxd;

figure, surface(xx, yy, zeros(size(xx)), outc, 'EdgeColor', 'none');
hold on, quiver(xx+binsz/2,yy+binsz/2, outdx, outdy);
axis square
toc