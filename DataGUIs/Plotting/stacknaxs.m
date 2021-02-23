function out = stacknaxs(axs, la)

if nargin < 2
    la = 'xy';
end

len = length(axs);

border = 0.1;
xlims = [border 1-border];
ylims = border + (1-border*2) * (0:len)/len ;


fg=figure;

%Does vdist to datacell{i} and plots them stacked
for i = len:-1:1
    ax = axs(i);
    axc(i) = copyobj(ax, fg);
    axc(i).Position = [xlims(1) ylims(i) diff(xlims) ylims(i+1)-ylims(i)];
end

%Clear x-axis text on plots
for i = 2:len
    axc(i).XTickLabel = {};
end

linkaxes(axc, la)

out = axc;