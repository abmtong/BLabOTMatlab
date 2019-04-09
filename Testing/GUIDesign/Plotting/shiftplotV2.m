function shiftplotV2()
%nudge with WASD
pan off
zoom off

global shiftamt
global curln
if isempty(shiftamt)
    shiftamt = [.1 10]; %shift amount in x, y
end


ax = gca;
fg = ancestor(ax, 'figure');

gobjs = get(ax, 'Children');
gobjs = gobjs(arrayfun(@(x)isa(x, 'matlab.graphics.chart.primitive.Line'), gobjs));

if isempty(curln)
    curln = gobjs(1);
end

    function keypf(~, edata)
        % global curln
        % global shiftamt
        switch edata.Key
            case 'd'
                curln.XData = curln.XData + shiftamt(1);
            case 'a'
                curln.XData = curln.XData - shiftamt(1);
            case 'w'
                curln.YData = curln.YData + shiftamt(2);
            case 's'
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