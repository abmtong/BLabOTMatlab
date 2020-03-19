function stepmap()
figure, hold on
xlim([0 4])
ylim([-1 4])

reg = plot([1 1], [0 3.4], 'Color', nicecolors(11));
dln1 = plot([.75, 1.25], 0*[.85 .85], 'Color', nicecolors(11));
dln2 = plot([.75, 1.25], 1*[.85 .85], 'Color', nicecolors(11));
dln3 = plot([.75, 1.25], 2*[.85 .85], 'Color', nicecolors(11));
dln4 = plot([.75, 1.25], 3*[.85 .85], 'Color', nicecolors(11));
dln5 = plot([.75, 1.25], 4*[.85 .85], 'Color', nicecolors(11));

r1 = plot([2 2], [0 2.9], 'Color', nicecolors(9));
rln1 = plot(2 + [-.25, .25], 0*[.85 .85], 'Color', nicecolors(9));
rln2 = plot([1.75, 2.25], 1*[.85 .85], 'Color', nicecolors(9));
rln3 = plot([1.75, 2.25], 2*[.85 .85], 'Color', nicecolors(9));
rln4 = plot([1.75, 2.25], 3*[.85 .85], 'Color', nicecolors(9));
rln5 = plot([1.75, 2.25], [2.9 2.9], 'Color', nicecolors(9));

r2 = plot([3 3], [0 2.9], 'Color', nicecolors(9));
r2ln1 = plot(3 + [-.25, .25], 0*[.725 .725], 'Color', nicecolors(9));
r2ln2 = plot([2.75, 3.25], 1*[.725 .725], 'Color', nicecolors(9));
r2ln3 = plot([2.75, 3.25], 2*[.725 .725], 'Color', nicecolors(9));
r2ln4 = plot([2.75, 3.25], 3*[.725 .725], 'Color', nicecolors(9));
r2ln5 = plot([2.75, 3.25], 4*[.725 .725], 'Color', nicecolors(9));

lns = get(gca,'Children');

arrayfun(@(x)set(x, 'LineWidth', 4), lns);