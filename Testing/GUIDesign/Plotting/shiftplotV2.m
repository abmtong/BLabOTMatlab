function shiftplotV2(gobjs)
%nudge with WASD
pan off
zoom off

global shiftamt
global curln


if nargin < 1
    ax = gca;
    fg = ancestor(ax, 'figure');
    gobjs = get(ax, 'Children');
    gobjs = gobjs(arrayfun(@(x)isa(x, 'matlab.graphics.chart.primitive.Line'), gobjs));
else
    fg = ancestor(gobjs(1), 'figure');
    ax = ancestor(gobjs(1), 'axes');
end
if isempty(shiftamt)
    shiftamt = [range(ax.XLim) range(ax.YLim)]/100; %shift amount in x, y
end
curln = gobjs(1);

    function keypf(~, edata)
        % global curln
        % global shiftamt
        shiftamt = [range(ax.XLim) range(ax.YLim)]/100;
        switch edata.Key
            case {'d' 'rightarrow'}
                curln.XData = curln.XData + shiftamt(1);
            case {'a' 'leftarrow'}
                curln.XData = curln.XData - shiftamt(1);
            case {'w' 'uparrow'}
                curln.YData = curln.YData + shiftamt(2);
            case {'s' 'downarrow'}
                curln.YData = curln.YData - shiftamt(2);
            otherwise
        end
    end

    function bdf(ob,~)
        % global curln
        curln = ob;
    end

set(fg, 'KeyPressFcn', @keypf)
set(fg, 'WindowKeyPressFcn', @keypf)
set(gobjs, 'ButtonDownFcn', @bdf)

end