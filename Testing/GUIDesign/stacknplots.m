function ax= stacknplots(xcell, ycell)

lims = [.1 .1 .8 .8]; %xstart ystart xlen ylen

n = length(xcell);
ax = gobjects(1, n);
ycell = ycell(end:-1:1);

for i = 1:n
    ax(i) = axes('Position', [ lims(1) lims(2) + (i-1)/n * lims(4) lims(3) lims(4)/n ] );
    bar(ax(i), xcell{i}, ycell{i})
end
linkaxes(ax, 'xy')
%remove xlabels from non-bottom graph
arrayfun(@(x)set(x, 'XTickLabel', {}), ax(2:end))