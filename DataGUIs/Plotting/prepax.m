function prepax(ax, fg)
if nargin < 1
    ax = gca;
end

if nargin < 2
    fg = gcf;
end


ax.FontSize = 16;
%test comment
% xlabel(ax, 'Time (s)');
% ylabel(ax, 'Contour Length (nm)');

% axis tight
aspectratio = 1;


% ax.XLim = [0 120];
% ax.YLim = [0 2000];
% ax.XTickLabel = {'5-15pN' '' '15-25pN' '' '25-35pN'};
% ax.XLim = [-inf inf];
% ax.YLim = [-inf inf];

pos = fg.Position;
% newfgxy = [960 540]; %for 16x9
newfgxy = [720/1 540*1]; %for 4x3
fg.Position = [pos(1:2) newfgxy];
fg.Color = [1 1 1];
% set(gcf, 'Color', [1 1 1])
global npics;
if isempty(npics)
    npics = 0;
else
    npics = npics + 1;
end
print(gcf, '-dpng', sprintf('fig%04d.png', npics), '-r192')


