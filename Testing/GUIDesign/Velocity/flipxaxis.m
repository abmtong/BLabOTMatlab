function flipxaxis(ax)
%Reverses the X axis on a plot
%Used to make velocities in @phagepause positive

if nargin < 1
    ax = gca;
end

%For every object in the axis, negate its X values
ch = ax.Children;
for c = ch
    if isa(c, 'matlab.graphics.chart.primitive.Line')
        c.XData = -c.XData;
    elseif isa(c, 'matlab.graphics.primitive.Text')
        c.Position = bsxfun(@times, c.Position, [-1 1 1]) ; %Why did I use bsxfun here? c should be a scalar, no? -> just .* then
    end
end