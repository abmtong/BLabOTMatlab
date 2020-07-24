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

