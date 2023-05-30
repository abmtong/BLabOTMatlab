function ezSum_plot(inst, frs, str)
%Plots the output of ezSum_batch

if nargin < 2 || isempty(frs)
    frs = 1:length( inst(1).vals1 );
end

if nargin < 3
    str = [];
end

%Get x-axis, which is frame #s sorted
xx = unique(frs);

%Set up figure: three plots, ch1, ch2, and both
figure('Name', sprintf( 'ezSum, N=%d %s', length(inst), str))
ax1 = subplot(3,1,1);
ax2 = subplot(3,1,2);
ax3 = subplot(3,1,3);

hold(ax1, 'on')
hold(ax2, 'on')
hold(ax3, 'on')

%Plot individual traces and sums, also take median
val1mtr = reshape( [inst.vals1], length(inst(1).vals1), [] );
val2mtr = reshape( [inst.vals2], length(inst(1).vals2), [] );

medtr1 = median(val1mtr, 2);
medtr2 = median(val2mtr, 2);

plot(ax1, xx, val1mtr);
plot(ax1, xx, medtr1, 'k', 'LineWidth', 2);


plot(ax2, val2mtr);
plot(ax2, xx, medtr2, 'k', 'LineWidth', 2);

%Rescale to have equal dynamic range
plot(ax3, xx, (medtr1 - min(medtr1)) / (max(medtr1) - min(medtr1))  , 'g', 'LineWidth', 1);
plot(ax3, xx, (medtr2 - min(medtr2)) / (max(medtr2) - min(medtr2)) , 'r', 'LineWidth', 1);

%Name and labels
title(ax1, 'Channel 1')
title(ax2, 'Channel 2')
title(ax3, 'Median Comparison')
axis([ax1 ax2 ax3], 'tight')
linkaxes([ax1 ax2 ax3], 'x')