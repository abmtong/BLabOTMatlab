function edthingv2(inx,iny, binsz)
%now just add vectors

tic
if nargin < 1
    inx = randn(1,1e7); %100kHz * 100s = 1e7 pts
    iny = randn(1,1e7); %100kHz * 100s = 1e7 pts
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
% dinxh = dinx;
% dinyh = diny;

%shift indata to natural coords
inx = floor(inx / binsz);
iny = floor(iny / binsz);

xoff = min(inx);
yoff = min(iny);

inx = inx - xoff + 1;
iny = iny - yoff + 1;

xr = max(inx);
yr = max(iny);

len = length(inx);
outc = zeros(xr,yr);
outdx = zeros(xr,yr);
outdy = zeros(xr,yr);


for i = 1:len-1
    outc(inx(i), iny(i)) = outc(inx(i), iny(i)) + 1;
    outdx(inx(i), iny(i)) = outdx(inx(i), iny(i)) + dinxh(i);
    outdy(inx(i), iny(i)) = outdy(inx(i), iny(i)) + dinyh(i);
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