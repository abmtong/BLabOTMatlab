function [plt, xx, yy] = barwid(cts, edges, norm)
%Plots like bar but allows for non-equal edges
%Normalizes by bin width if norm == 1

if nargin < 3
    norm = 1;
end

xx = (edges(1:end-1) + edges(2:end)) / 2;
wids = diff(edges);

[uw, ~, uc] = unique(wids);

if norm
    cts = cts./wids;
end

tfh = ishold;
hold on

plts = gobjects(1, length(uw));
for i = 1:length(uw)
    yy = cts;
    yy(uc ~= i) = 0;
    plts(i) = bar(xx, yy, 'BarWidth', .8* uw(i));
end

if ~tfh
    hold off
end

if nargout > 1
    plt = plts;
end
