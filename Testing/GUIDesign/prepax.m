function prepax(ax, fg)
if nargin < 1
    ax = gca;
end

if nargin < 2
    fg = gcf;
end


ax.FontSize = 16;

% xlabel(ax, 'Time(s)');
% ylabel(ax, 'Contour (DNA bp, nm/0.34)');

% ax.XLim = [0 200];
% ax.YLim = [0 4000];

pos = fg.Position;
% newfgxy = [960 540]; %for 16x9
newfgxy = [720 540]; %for 4x3
fg.Position = [pos(1:2) newfgxy];
fg.Color = [1 1 1];
% set(gcf, 'Color', [1 1 1])

print(gcf, '-dpng', 'fig.png', '-r192')