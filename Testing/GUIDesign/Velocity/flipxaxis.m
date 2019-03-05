function flipxaxis(ax)

if nargin < 1
    ax = gca;
end

ch = ax.Children;

for i = 1:length(ch)
    c = ch(i);
    if isa(c, 'matlab.graphics.chart.primitive.Line')
        c.XData = -c.XData;
    elseif isa(c, 'matlab.graphics.primitive.Text')
        c.Position = bsxfun(@times, c.Position, [-1 1 1]) ;
    end
end