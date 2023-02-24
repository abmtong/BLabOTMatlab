function plotFrcExtKymo(frc, ext, kymo, dt1, dt2)
%Plots on one figure force, distance, kymo; linked x-axis

fg = figure;
ax1 = subplot2(fg, [3 1], 1);
ax2 = subplot2(fg, [3 1], 2);
ax3 = subplot2(fg, [3 1], 3);

plot(ax1, (1:length(frc))*dt1, frc)
plot(ax2, (1:length(ext))*dt1, ext)

[xx, yy] = meshgrid( 1:size(kymo, 2), 1:size(kymo, 1) );
surface(ax3, xx*dt2, yy, kymo, 'EdgeColor', 'none')
colormap hot

axis(ax1, 'tight')
axis(ax2, 'tight')
axis(ax3, 'tight')

linkaxes( [ax1 ax2 ax3], 'x')