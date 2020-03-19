function fretplot()

load cy3cy5spec.mat

addpath('..') % add nicecolors

fig = figure;
hold on
area(cy3abs(:,1),cy3abs(:,2), 'EdgeColor', nicecolors(10), 'FaceColor', nicecolors(10), 'FaceAlpha', .5)
area(cy3emi(:,1),cy3emi(:,2), 'EdgeColor', nicecolors(9), 'FaceColor', nicecolors(9), 'FaceAlpha', .5)

area(cy5abs(:,1),cy5abs(:,2), 'EdgeColor', nicecolors(2), 'FaceColor', nicecolors(2), 'FaceAlpha', .5)
area(cy5emi(:,1),cy5emi(:,2), 'EdgeColor', nicecolors(1), 'FaceColor', nicecolors(1), 'FaceAlpha', .5)

ylim([.05, 1])

xlabel Wavelength(nm)
ylabel Absorbance(au)

print(fig, outname,'-dpng',sprintf('-r%d',96*2))