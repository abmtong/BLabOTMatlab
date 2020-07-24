function plotraw(insd)

ax = insd.forceAX;
bx = insd.forceBX;
ay = insd.forceAY;
by = insd.forceBY;
t = insd.time;

figure Name PlotRaw
axs(1) = subplot(3,1,1); hold on
title('Force')
cellfun(@(x,y)plot(x,-y, 'Color', 'b'), t, ax)
cellfun(@(x,y)plot(x,y, 'Color', 'g'), t, bx)
cellfun(@(x,y)plot(x,-y, 'Color', 'b'), t, ay)
cellfun(@(x,y)plot(x,y, 'Color', 'g'), t, by)

kax = insd.cal.AX.k;
kbx = insd.cal.BX.k;
kay = insd.cal.AY.k;
kby = insd.cal.BY.k;
axis tight

axs(2) = subplot(3,1,2); hold on
title('BeadEx')
cellfun(@(x,y)plot(x,-y/kax, 'Color', 'b'), t, ax)
cellfun(@(x,y)plot(x,y/kbx, 'Color', 'g'), t, bx)
cellfun(@(x,y)plot(x,-y/kay, 'Color', 'b'), t, ay)
cellfun(@(x,y)plot(x,y/kby, 'Color', 'g'), t, by)

aax = insd.cal.AX.k * insd.cal.AX.a;
abx = insd.cal.BX.k * insd.cal.BX.a;
aay = insd.cal.AY.k * insd.cal.AY.a;
aby = insd.cal.BY.k * insd.cal.BY.a;
axis tight

axs(3) = subplot(3,1,3); hold on
title('NormVolt')
cellfun(@(x,y)plot(x,-y/aax, 'Color', 'b'), t, ax)
cellfun(@(x,y)plot(x,y/abx, 'Color', 'g'), t, bx)
cellfun(@(x,y)plot(x,-y/aay, 'Color', 'b'), t, ay)
cellfun(@(x,y)plot(x,y/aby, 'Color', 'g'), t, by)
linkaxes(axs, 'x');
axis tight

