function axslider(inax, nframes, outname)

xl = inax.XLim;
yl = inax.YLim;
axp= inax.Position;

%overlay axes copy
% ax = axes('Position', axp, 'XLim', xl, 'YLim', yl,'XTick', [], 'YTick', []);
fig = figure;
ax = copyobj(inax, fig);
ax2 = copyobj(inax, fig);

%make its background transparent
set(ax2, 'Color', 'none');
box on

%delete its lines
arrayfun(@delete, ax2.Children)

%draw a  white rectangle to blank out some of the frame
x1 = xl(1);
x2 = xl(2);
dx = (x2 - x1) / nframes;
y1 = yl(1);
y2 = yl(2);
for i = 0:nframes
    %draw a rectangle
    rec = rectangle(ax, 'Position', [x1 + dx*i, y1, x2, y2-y1], 'EdgeColor', [1 1 1], 'FaceColor', [1 1 1]);
    drawnow
    pause(.1)
    %save
    if nargin > 2
        scale = 3;
        print(fig, sprintf('.\\%s\\%s%0.4d',outname,outname,i),'-dpng',sprintf('-r%d',96*scale))
    end
    delete(rec)
end