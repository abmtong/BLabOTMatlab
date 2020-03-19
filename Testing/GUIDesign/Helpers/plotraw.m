function plotraw(insd)
%Plots raw data [{Force, Bead Ext, NV} x {XY} x {AB}]

if isfield(insd, 'cut');
    ax = [insd.forceAX insd.cut.forceAX];
    bx = [insd.forceBX insd.cut.forceBX];
    ay = [insd.forceAY insd.cut.forceAY];
    by = [insd.forceBY insd.cut.forceBY];
    t =  [insd.time insd.cut.time];
else
    ax = insd.forceAX;
    bx = insd.forceBX;
    ay = insd.forceAY;
    by = insd.forceBY;
    t = insd.time;
end

plotAX = @(xx,yy,zz) cellfun(@(x,y)plot(x,-zz(y), 'Color', 'b'), xx, yy); %b = [0 0 1]
plotBX = @(xx,yy,zz) cellfun(@(x,y)plot(x,zz(y), 'Color', 'g'), xx, yy); %g =  [0 1 0]
plotAY = @(xx,yy,zz) cellfun(@(x,y)plot(x,-zz(y), 'Color', [.5 .5 1]), xx, yy);
plotBY = @(xx,yy,zz) cellfun(@(x,y)plot(x,zz(y), 'Color', [.5 1 .5]) , xx, yy);

%Get spring parameters
kax = insd.cal.AX.k;
kbx = insd.cal.BX.k;
kay = insd.cal.AY.k;
kby = insd.cal.BY.k;
aax = kax * insd.cal.AX.a;
abx = kbx * insd.cal.BX.a;
aay = kay * insd.cal.AY.a;
aby = kby * insd.cal.BY.a;

figure('Name', 'PlotRaw')
%Plot force
axs(1) = subplot(3,1,1); hold on
title('Force')
plotAX(t,ax,@(x)x)
plotBX(t,bx,@(x)x)
plotAY(t,ay,@(x)x)
plotBY(t,by,@(x)x)
axis tight

%Plot bead extension
axs(2) = subplot(3,1,2); hold on
title('BeadEx')
plotAX(t,ax,@(x)x/kax)
plotBX(t,bx,@(x)x/kbx)
plotAY(t,ay,@(x)x/kay)
plotBY(t,by,@(x)x/kby)
axis tight

%Plot normalized volts
axs(3) = subplot(3,1,3); hold on
title('NormVolt')
plotAX(t,ax,@(x)x/aax)
plotBX(t,bx,@(x)x/abx)
plotAY(t,ay,@(x)x/aay)
plotBY(t,by,@(x)x/aby)
linkaxes(axs, 'x');
axis tight


