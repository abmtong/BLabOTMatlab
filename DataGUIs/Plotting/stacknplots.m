function ax= stacknplots(xcell, ycell)

lims = [.1 .1 .8 .8]; %xstart ystart xlen ylen

n = length(ycell);
ax = gobjects(1, n);

if ~iscell(xcell)
    xcell = repmat({xcell}, 1, n);
end

%Flip xcell order, so top = 1
xcell = xcell(end:-1:1);
ycell = ycell(end:-1:1);

for i = 1:n
    ax(i) = axes('Position', [ lims(1) lims(2) + (i-1)/n * lims(4) lims(3) lims(4)/n ] );
    plot(ax(i), xcell{i}, ycell{i})
end
% linkaxes(ax, 'xy')
linkaxes(ax, 'x')
%remove xlabels from non-bottom graph
arrayfun(@(x)set(x, 'XTickLabel', {}), ax(2:end))