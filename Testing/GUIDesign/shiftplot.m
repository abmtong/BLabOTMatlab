function shiftplot(gobjs, varargin)

for i = 1:length(gobjs)
    tmp = gobjs(i);
    if isa(tmp, 'matlab.graphics.GraphicsPlaceholder')
        continue %do nothing
    end
    if isa(tmp, 'matlab.graphics.chart.primitive.Line')
        for j = 1:length(varargin)
            switch j %is there a better way to do this?
                case 1
                    tmp.XData = tmp.XData + varargin{1};
                case 2
                    tmp.YData = tmp.YData + varargin{2};
                case 3
                    tmp.ZData = tmp.ZData + varargin{3};
                otherwise
                    fprintf('Too many @shiftplot args for Line, %d-%d', j, length(varargin))
                    break
            end
        end
    end
    if isa(tmp, 'matlab.graphics.primitive.Text')
        for j = 1:length(varargin)
            switch j %is there a better way to do this?
                case 1
                    tmp.Position(1) = tmp.Position(1) + varargin{1};
                case 2
                    tmp.Position(2) = tmp.Position(2) + varargin{2};
                case 3
                    tmp.Position(3) = tmp.Position(3) + varargin{3};
                otherwise
                    fprintf('Too many @shiftplot args for Text, %d-%d', j, length(varargin))
                    break
            end
        end
    end
end
