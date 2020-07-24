function stlbatch(axs, pre)


if nargin < 2
    pre = 'stl';
end
if nargin < 1
    axs = gca;
end


ch = axs.Children;

for i = 1:length(ch)
    if isa(ch(i), 'matlab.graphics.chart.primitive.Surface')
        x = ch(i).XData;
        y = ch(i).YData;
        z = ch(i).ZData;
        surf2stl(sprintf('%s%03d.stl', pre, i), x(1:end, 1:end-1), y(1:end, 1:end-1), z(1:end, 1:end-1))
%         stlwrite(sprintf('%s%03d.stl', pre, i), x(1:end, 1:end-1), y(1:end, 1:end-1), z(1:end, 1:end-1))
    end
end