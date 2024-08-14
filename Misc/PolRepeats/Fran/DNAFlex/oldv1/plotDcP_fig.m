function plotDcP_fig(dat, nbp)
%plotDcP all of them


if nargin < 2
    nbp = 301;
end

if nargin < 1 || isempty(dat)
    %Process .mat files and save as _dcpplotall.fig
    [f, p] = uigetfile('Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    len = length(f);
    for i = 1:len
        infp = fullfile(p, f{i});
        [pp, ff, ~] = fileparts(infp);
        outfp = fullfile(pp, [ff '_dcpplot.fig']);
        
        %Load file
        tmp = load(infp);
        fns = fieldnames(tmp);
        tmp = tmp.(fns{1}); %Assume it's only one field
        plotDcP_fig(tmp);
        fg = gcf;
        savefig(fg, outfp)
        delete(fg)
    end
    return
end





%Make figure
fg = figure('Name', 'plotDcP_fig', 'Color', [1 1 1]);

%PlotDcP : goes in up-left corner
plotDcP(dat, nbp)
fg1 = gcf;
ax1 = copyobj(fg1.Children, fg);
ax1(end).Position = [.05 .55 .40 .40];

%v2 : bottom-left
plotDcPv2(dat, nbp)
fg2 = gcf;
ax2 = copyobj(fg2.Children, fg);
ax2(end).Position = [.05 .05 .40 .40];

%_bar : right
plotDcP_bar(dat, nbp)
fg3 = gcf;
ax3 = copyobj(fg3.Children, fg);
ax3(end).Position = [.55 .05 .40 .90];
colorbar(ax3(end))
colormap(ax3(end), 'jet')

delete([fg1 fg2 fg3])
