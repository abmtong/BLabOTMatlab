function out = getnorm(euls, order)

if nargin < 2
    order = 'ZYZ';
end

eul1 = euls(:,1);
eul2 = euls(:,2);
eul3 = euls(:,3);


len = length(eul1);

rot = zeros(len,3);
outaz = zeros(1,len);
outel = zeros(1,len);
outr = zeros(1,len);
for i = 1:len
    rot(i,:) = eul2rotm([eul1(i) eul2(i) eul3(i)]/180*pi, order) * [0 0 1]';
    [outaz(i), outel(i), outr(i)] = cart2sph(rot(i,1), rot(i,2), rot(i,3));
end

%Draw a 2d histogram of the angle distribution. Draw like a map projection (rectiliniear)
figure
nbin = 50;
[n, xe, ye] = histcounts2(outaz, outel, nbin);

%Scale by volume by dividing by cos(elevation)
% n = bsxfun(@rdivide, n, cos((ye(1:end-1) + ye(2:end))/2));

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

if nargout
    out = rot;
end
