function plottrcforfig(incon, toff, coff, filt, linhei, linoff)

col = 'b';

figure
hold on

tim = 0;
for i = 1:length(incon)
    con =incon{i};
    con = con-con(1);
    ttmp = tim + (1:length(con))/2500;
    plot( ttmp + toff(i), con + coff(i), 'Color', [.7 .7 .7])
    cf = windowFilter(@mean, con, filt, 1);
    plot( ttmp + toff(i), cf + coff(i), 'Color', col)
    tim = tim + ttmp(end);
end

axis tight

xl= xlim;
yl = ylim;

ys = ceil(max(abs(yl/linhei)));
ys = -ys:ys;
ys = ys * linhei + linoff;

for i = 1:length(ys)
    line(xl, ys(i) * [1 1], 'Color', [.4 .4 .4], 'LineStyle', ':', 'LineWidth', 2)
end