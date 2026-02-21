function out = fitSpotRadius(inx, iny)


fitfcn = @(x0,x) 1- exp( -x.^2 / 2 / x0^2 );

ft = lsqcurvefit(fitfcn, 3, inx, iny);

out = ft;

figure, hold on
plot(inx, iny, 'o')

xx = 0:.1:max(inx);
yy = fitfcn(ft, xx);
plot( xx, yy, 'k')
title(sprintf('Radius %0.3f', ft))