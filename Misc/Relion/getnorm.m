function out = getnorm(euls, order)

if nargin < 2
    order = 'ZYZ';
end

eul1 = euls(:,1);
eul2 = euls(:,2);
eul3 = euls(:,3);


len = length(eul1);

out = zeros(len,3);
outaz = zeros(1,len);
outel = zeros(1,len);
outr = zeros(1,len);
for i = 1:len
    out(i,:) = eul2rotm([eul1(i) eul2(i) eul3(i)]/180*pi, order) * [0 0 1]';
    [outaz(i), outel(i), outr(i)] = cart2sph(out(i,1), out(i,2), out(i,3));
end

%Draw a 2d histogram of the angle distribution. Draw like a map projection (rectiliniear)
figure
nbin = 200;
[n, xe, ye] = histcounts2(outaz, outel, nbin);

%Scale by volume
n = bsxfun(@rdivide, n, cos(xe(1:end-1) + xe(2:end)));

xe = xe / pi * 180;
ye = ye / pi * 180;

[xx, yy] = meshgrid((xe(1:end-1) + xe(2:end)) /2, (ye(1:end-1) + ye(2:end))/2);
surf(xx,yy,n', 'EdgeColor', 'none', 'FaceColor', 'interp')
xlabel('Azimuth (Angle on XY plane) (deg)')
ylabel('Elevation (Angle with XY plane) (deg)')
title('Rectilinear projection heatmap')
axis tight
ax=gca;
ax.CameraPosition = [ 0 0 max(n(:))*2];
ax.CameraTarget = [0 0 0];
colormap pink
colorbar

%{

%convert to polar for plotting

% figure, hist(out(:,1), 50);
% figure, hist(out(:,2), 50);
% figure, hist(out(:,3), 50);

fg = figure;
ax = subplot2(fg, [2 3], 1);
hist(ax, out(:,1), 50);
title(ax, 'X')

ax = subplot2(fg, [2 3], 3);
hist(ax, out(:,2), 50);
title(ax, 'Y')

ax = subplot2(fg, [2 3], 5);
hist(ax, out(:,3), 50);
title(ax, 'Z')

ax = subplot2(fg, [2 3], 2);
hist(ax, eul1, 50);
title(ax, 'EulAng_1')

ax = subplot2(fg, [2 3], 4);
hist(ax, eul2, 50);
title(ax, 'EulAng_2')

ax = subplot2(fg, [2 3], 6);
hist(ax, eul3, 50);
title(ax, 'EulAng_3')
%}
