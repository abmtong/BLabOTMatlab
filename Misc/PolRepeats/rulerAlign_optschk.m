function rulerAlign_optschk(trs, trop)

pers = [.005 .01 .02 .05 .10];

%Draw as lines
len = length(pers);
xs = cell(1,len);
ys = cell(1,len);
op = trop;
for i = 1:len
    op.perschd = pers(i);
    op.binsm = (pers(i) / trop.perschd)^-1 * trop.binsm;
    op.verbose = 0;
    [~, or] = rulerAlignV2(trs, op);
    x = [or.off];
    xs{i} = x(:);
    y = [or.scl];
    ys{i} = y(:);
end

%Make matrix
xs = [xs{:}];
ys = [ys{:}];

%Now plot as lines
fg = figure;
ax = gca;
hold(ax, 'on')

for i = 1:size(xs,1)
    x = xs(i,:);
    y = ys(i,:);
    z = (1:len);
    surface(ax, [x;x], [y;y], [z;z] , 'LineWidth', 2, 'EdgeColor', 'interp');
    scatter(x,y, '*')
end

colorbar
colormap jet






