function out = pol_dwelldist_p3(xlabs, ylabs, dat, date)
%After p2, hand-check the fitting for anomalous rates (in the .xls), then paste tables as rate mtxs
%Make one graph per column in ylabs

%If no error supplied, don't plot
if nargin < 4
    date = zeros(size(dat));
end

nx = length(xlabs);
ny = length(ylabs);

for i = 1:ny
    %Name figure
    figure('Name', ylabs{i})
    hold on
    
    %Plot bar
    bar(dat(:,i))
    
    %Plot errors
    errorbar(dat(:,i), date(:,i), 'LineStyle', 'none');
    
    %Setup x axis
    ax = gca;
    ax.XTickLabelMode = 'manual';
    ax.XTick = 1:nx;
    ax.XTickLabel = xlabs;
    ax.TickLabelInterpreter = 'none';
end
