function out = zjRTH(iny, inOpts)

%Plot a RTH that looks like in Chen paper

opts.color = [1 0 0]; %Default red


if nargin > 1
    opts = handleOpts(opts, inOpts);
end


fg = figure('Position', [88 725 984 246]);
fg.Color = [1 1 1];
ax = gca;

%Plot with @bar
x = 1:length(iny);

bar(x, iny, 1, 'EdgeColor', 'none', 'FaceColor', opts.color)

xlim([0 x(end)+1])

%Draw dotted lines at 1, 74, 147
locs = [1 74 147];
for i = locs
    line(i * [1 1], [0 10], 'Color', [0 0 0], 'LineStyle', '--')
end
% axis tight
ylim([0 3])
xlim([0 locs(end)+1])
xlabel('Transcribed distance (bp)')
ylabel('RT (s)')
box off
ax.TickDir = 'out';
ax.FontSize = 18;