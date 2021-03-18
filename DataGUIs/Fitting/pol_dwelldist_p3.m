function pol_dwelldist_p3(xlabs, ylabs, dat, daterr)
%Plots the rates matrix from p2
%Meant for [a1, k1, a2, k2, ...] along columns of dat/daterr, xlabs/ylabs is table labels

%If no error supplied, don't plot
if nargin < 4
    daterr = zeros(size(dat));
end

nx = length(xlabs);
ny = length(ylabs);

fg = figure('Name', 'Pol Dwelldist', 'Color', [1 1 1]);

for i = 1:ny
    ax =  subplot2(fg, [2 round(ny/2)], i );
    hold(ax, 'on')
    
    %Plot bar
    bar(ax, dat(:,i), 'FaceColor', [.5 .5 1])
    
    %Plot errors
    errorbar(ax, dat(:,i), daterr(:,i), 'LineStyle', 'none');
    
    %Setup x axis
    ax.XTickLabelMode = 'manual';
    ax.XTick = 1:nx;
    ax.XTickLabel = xlabs;
    ax.XTickLabelRotation = 90;
    ax.TickLabelInterpreter = 'none';
    
    %Font/etc.
    title(ax, ylabs{i})
    ax.FontSize = 14;
end
