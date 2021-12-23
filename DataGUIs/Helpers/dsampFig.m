function out = dsampFig(infig, dsfact)


maxlen = 1e2;

if nargin < 2
    dsfact = 10;
end

if nargin < 1 || isempty(infig)
    infig = gcf;
end

%For each child
ch = infig.Children;
for i = 1:length(ch)
    %For each axis
    if isa(ch(i), 'matlab.graphics.axis.Axes')
        c = ch(i).Children;
        for j = 1:length(c)
            %Check if is line
            if isa(c(j), 'matlab.graphics.chart.primitive.Line')
                x = c(j).XData;
                y = c(j).YData;
                %If it's a sufficiently large line, downsample it
                if length(x) > maxlen
                    x = windowFilter(@mean, x, [], dsfact);
                    y = windowFilter(@mean, y, [], dsfact);
                    set(c(j), 'XData', x, 'YData', y)
                end
            end
        end
    end
end




