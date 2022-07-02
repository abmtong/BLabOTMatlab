function out = setNucLims(ax)
if nargin < 1
    ax = gca;
end

xlim(ax, [0 150])
ylim(ax, [0 4])
