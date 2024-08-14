function [out, axs] = ezSum_plotunnorm(inst, frs, str, prc, axs)
%Plots the output of ezSum_batch

if nargin < 2 || isempty(frs)
    frs = 1:length( inst(1).vals1 );
end

if nargin < 3
    str = [];
end

if nargin < 4 || isempty(prc)
    prc = 50;
end

%Get x-axis, which is frame #s sorted
xx = unique(frs);

if nargin < 5 || isempty(axs)
    %Set up figure: three plots, ch1, ch2, and both
    figure('Name', sprintf( 'ezSum, N=%d %s', length(inst), str))
    ax1 = subplot(3,1,1);
    ax2 = subplot(3,1,2);
    ax3 = subplot(3,1,3);
    hold(ax1, 'on')
    hold(ax2, 'on')
    hold(ax3, 'on')
else %Use given axes
    ax1 = axs(1);
    ax2 = axs(2);
    ax3 = axs(3);
end

%Zero background:
len = length(inst);
tmp1=cell(1,len);
tmp2=cell(1,len);
for i = 1:len
    tmp=inst(i);
    
    if ~isempty(tmp.frraw{1}) && ~isempty(tmp.frraw{2}) 
        tmp1{i} = tmp.vals1 - tmp.frraw{1}{1}{2};
        tmp2{i} = tmp.vals2 - tmp.frraw{2}{1}{2};
    end
end


%Plot individual traces and sums, also take median
val1mtr = reshape( [tmp1{:}], length(inst(1).vals1), [] );
val2mtr = reshape( [tmp2{:}], length(inst(1).vals2), [] );

% medtr1 = prctile(val1mtr, prc, 2);
% medtr2 = prctile(val2mtr, prc, 2);

medtr1 = mean(val1mtr,  2);
medtr2 = mean(val2mtr,  2);

plot(ax1, xx, val1mtr);
plot(ax1, xx, medtr1, 'k', 'LineWidth', 2);


plot(ax2, xx, val2mtr);
plot(ax2, xx, medtr2, 'k', 'LineWidth', 2);

%Rescale to have equal dynamic range
% plot(ax3, xx, (medtr1 - min(medtr1)) / (max(medtr1) - min(medtr1))  , 'g', 'LineWidth', 1);
% plot(ax3, xx, (medtr2 - min(medtr2)) / (max(medtr2) - min(medtr2)) , 'r', 'LineWidth', 1);

plot(ax3, xx, (medtr1) , 'g', 'LineWidth', 1);
plot(ax3, xx, (medtr2) , 'r', 'LineWidth', 1);


%Name and labels
title(ax1, 'Channel 1')
title(ax2, 'Channel 2')

if prc == 50
    title(ax3, 'Median Comparison')
else
    title(ax3, sprintf('%dth percentile Comparison', prc))
end
axis([ax1 ax2 ax3], 'tight')
linkaxes([ax1 ax2 ax3], 'x')

axs = [ax1 ax2 ax3];
out = [xx(:) medtr1(:) medtr2(:)];






