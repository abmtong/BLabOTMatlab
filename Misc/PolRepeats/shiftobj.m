function out = shiftobj(amt, dir)
if nargin < 2
    dir = 'x';
end


ob = gco;
switch dir
    case 'x'
        try
            ob.XData = ob.XData + amt;
        catch
        end
    case 'y'
        try
            ob.YData = ob.YData + amt;
        catch
        end
    otherwise
end
