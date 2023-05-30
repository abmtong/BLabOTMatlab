function out = addbutton(fg, type)
%adds a button that will do something to a graph, like measure, stepfind, etc.

if nargin < 1 || isempty(fg)
    fg = gcf;
end

if nargin < 2
    type = 'measure';
end

if strcmpi(type, 'measure');
    out = uicontrol('Parent', fg, 'Units', 'normalized', 'Position', [ 0, 0, .1, .1], 'String', 'Measure', 'Callback',@(x,y)drawline);
    return
end

if strcmpi(type, 'shift')
    fg = gcf;
    fg.KeyPressFcn = @shift;
    out = fg;
    return
end

if strcmpi(type, 'Stepfind');
    out = uicontrol('Parent', fg, 'Units', 'normalized', 'Position', [ 0, 0, .1, .1], 'String', 'Measure', 'Callback',@(x,y)drawline);
end

if strcmpi(type, 'delete')
    out = uicontrol('Parent', fg, 'Units', 'normalized', 'Position', [ 0, 0, .1, .1], 'String', 'Delete', 'Callback',@(x,y)dellines);
end

    function ob = drawline(towrite)
        %if string has x, y, and/or m, state dx, dy, slope
        if nargin < 1
            towrite = 'xym';
        end
        
        [x, y] = ginput(2);
        
        ob = line(x, y);
        
        if ~isempty(towrite)
            str = '';
            arr = [];
            if any(towrite == 'x')
                str = [str 'dx = %0.2f, '];
                arr = [arr abs(diff(x))];
            end
            if any(towrite == 'y')
                str = [str 'dy = %0.2f, '];
                arr = [arr abs(diff(y))];
            end
            if any(towrite == 'm')
                str = [str 'm = %0.2g, '];
                arr = [arr abs(diff(y))/abs(diff(x))];
            end
            str = sprintf(str, arr);
            ob(2) = text(mean(x),mean(y), str);
        end
    end

    function out = stepfind()
        %Call ginput to set gca
        ginput(1)
        %Act on the top-most Line child of gca
        ax=gca;
        ch = ax.Children;
        
        
        %Run BatchKV, default params
        BatchKV(data, single(5));
    end

    function shift(evt, fh)
        switch evt.Character
            case 'a'
                ob = gco;
                xwid = diff(xlim);
                if isfield(ob, 'XData')
                    ob.XData = ob.XData - xwid/20 ;
                end
            case 'd'
                ob = gco;
                xwid = diff(xlim);
                if isfield(ob, 'XData')
                    ob.XData = ob.XData + xwid/20 ;
                end
            otherwise
        end
    end

    function dellines(~, fh)
        %ginput(2), delete lines with data in the range defined by this box
        [xx, yy] = ginput(2);
        
        xx = sort(xx);
        yy = sort(yy);
        
        %Get axis
        ax = gca;
        %Get children
        ch = ax.Children;
        %Loop
        for i = 1:length(ch)
            %Check if x/y data exists
            if isprop(ch(i), 'XData') && isprop(ch(i),'YData')
                %If so, check if they're within this box
                ki = ch(i).XData >= xx(1) & ch(i).XData <= xx(2);
                tf = any( ch(i).YData(ki) >= yy(1) & ch(i).YData(ki) <= yy(2) );
                if tf
                    delete(ch(i))
                end
            end
        end
    end

end