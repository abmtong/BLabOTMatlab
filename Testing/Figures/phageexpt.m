function phageexpt()

fig = figure ('Position', [0 0 960 540]); hold on
ax = gca;
%trap 1, located at origin, radius 10
[cx, cy, cz] = hyperboloid(20, .4);
cz = cz * 51;
cc = colorscale(abs(cy),0,.1);
t1p = surface(cx, cy, cz, cc, 'EdgeColor', 'none', 'FaceLighting', 'none');
t1n = surface(cx, cy, -cz, cc, 'EdgeColor', 'none', 'FaceLighting', 'none');
%trap 2, located at +200
t2p = surface(cx, cy+100, cz, cc, 'EdgeColor', 'none', 'FaceLighting', 'none');
t2n = surface(cx, cy+100, -cz, cc, 'EdgeColor', 'none', 'FaceLighting', 'none');

ax.CLim = [0 1];
colormap(phagecolormap);
%make camera look around x
ax.CameraPosition = [100 0 0];
ax.CameraTarget = [0 0 0];
ax.DataAspectRatio = [1 1 1];
ax.ZLim = [-50 50];
% ax.
% axis square

[sx, sy, sz] = sphere(200);
sx = sx * 20;
sy = sy * 20;
sz = sz * 20;
%beads
% s1 = surface(sx+25, sy, sz, ones(size(sx)) , 'EdgeColor', 'none');
% s2 = surface(sx+25, sy+100, sz, ones(size(sx)) , 'EdgeColor', 'none');

% ax.XLim = [-20, 50];
li = light('Position', [50 50 50]);

%plot capsid
[hy, hz] = hexagon;
hy = hy * 10;
hz = hz * 10;
plot3(ones(size(hy)), hy+30, hz, 'LineWidth', 2, 'Color', 'k')

%plot motor


%save image
% if ~isempty(outname)
%     print(fig, outname,'-dpng',sprintf('-r%d',96*2))
%     close(fig);
% end