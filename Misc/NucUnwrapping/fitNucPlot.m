function fitNucPlot(inst)
%Plot an output struct of fitNuc

frng = [1.5 2.5 5 50];
fil = 100;

if length(inst) > 1
    arrayfun(@fitNucPlot, inst)
    return
end

%Get data
ext = double( windowFilter(@mean, inst.ext, [], fil) );
frc = double( windowFilter(@mean, inst.frc, [], fil) );
ft = inst.xwlc;

%Plot
figure
ax = gca;
hold(ax, 'on')
plot(ext, frc);
plot( XWLC(frc, ft(1), ft(2) )* ft(3) , frc)
plot( XWLC(frc, ft(1), ft(2) )* (ft(3)+ft(4)) , frc)
plot( XWLC(frc, ft(1), ft(2) )* (ft(3)+ft(5)) , frc)
yl = ylim;
xl = xlim;
arrayfun(@(x) plot( xl, [1 1]*x), frng)
% arrayfun(@(x,y) plot(x*[1 1], [0 y]), ext([i1 i2 i3 i3b i4b i4]) , [frng(1) frng(2) frng(3) frng(4) frng(4) yl(2) ]  )
