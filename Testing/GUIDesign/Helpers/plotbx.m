function plotbx(insd)

ax = insd.forceAX;
bx = insd.forceBX;
ay = insd.forceAY;
by = insd.forceBY;
t = insd.time;

figure Name Force, hold on
cellfun(@(x,y)plot(x,-y), t, ax)
cellfun(@(x,y)plot(x,y), t, bx)
cellfun(@(x,y)plot(x,-y), t, ay)
cellfun(@(x,y)plot(x,y), t, by)

kax = insd.cal.AX.k;
kbx = insd.cal.BX.k;
kay = insd.cal.AY.k;
kby = insd.cal.BY.k;

figure Name BeadEx, hold on
cellfun(@(x,y)plot(x,-y/kax), t, ax)
cellfun(@(x,y)plot(x,y/kbx), t, bx)
cellfun(@(x,y)plot(x,-y/kay), t, ay)
cellfun(@(x,y)plot(x,y/kby), t, by)

aax = insd.cal.AX.k * insd.cal.AX.a;
abx = insd.cal.BX.k * insd.cal.BX.a;
aay = insd.cal.AY.k * insd.cal.AY.a;
aby = insd.cal.BY.k * insd.cal.BY.a;

figure Name NormVolt, hold on
cellfun(@(x,y)plot(x,-y/aax), t, ax)
cellfun(@(x,y)plot(x,y/abx), t, bx)
cellfun(@(x,y)plot(x,-y/aay), t, ay)
cellfun(@(x,y)plot(x,y/aby), t, by)
