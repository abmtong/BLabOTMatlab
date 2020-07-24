function addbutton(fg, type)
%adds a button that will do something to a graph, like measure, stepfind, etc.

if nargin < 1
    fg = gcf;
end

if nargin < 2
    type = 'measure';
end

if strcmpi(type, 'measure');
    uicontrol('Parent', fg, 'Units', 'normalized', 'Position', [ 0, 0, .1, .1], 'String', 'Measure', 'Callback',@(x,y)drawline);
    return
end

if strcmpi(type, 'Stepfind');
    uicontrol('Parent', fg, 'Units', 'normalized', 'Position', [ 0, 0, .1, .1], 'String', 'Measure', 'Callback',@(x,y)drawline);
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
        str = [str 'm = %0.2f, '];
        arr = [arr abs(diff(y))/abs(diff(x))];
    end
    str = sprintf(str, arr);
    ob(2) = text(mean(x),mean(y), str);
end

function out = stepfind()
%Call ginput to set gca
ginput(1)
%Act on the top-most Line child of gca
ax=gca;
ch = ax.Children;


%Run BatchKV, default params
BatchKV(data, single(5));
