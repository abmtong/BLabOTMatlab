function [out, outraw] = getprotfromfig(fg)

protax = fg.Children(end-1);
histax = fg.Children(end-2);

protln = protax.Children(end-2);

px = protln.XData;
py = protln.YData;

histln = histax.Children(1);

hx = histln.XData;
hy = histln.YData;

out = {px py hx hy};

if nargout > 1
    ps1 = protax.Children(end);
    ps2 = protax.Children(end-1);
    outraw = { [ps1.XData ps2.XData] [ps1.YData ps2.YData] };
end