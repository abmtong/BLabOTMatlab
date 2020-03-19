function fit = fithygauss(inx, inp)
%fit 3 gaussians, at .85, .5, 1.2

fitfcn = @(f, x) normpdf(x, f(1), f(2)) * f(3) + normpdf(x, f(4), f(5)) * f(6) + normpdf(x, f(7), f(8)) * f(9);
fitfcn = @(f, x) normpdf(x, f(1), f(2)) * f(3) + normpdf(x, f(4), f(5)) * f(6) + normpdf(x, f(7), f(8)) * (f(3) - 3*f(6)) /2;
gau = @(f,x) normpdf(x, f(1), f(2)) * f(3);

mn1 = 2.5*.34;
mn2 = mn1 - .34 * 1;
mn3 = mn1 + .34 * 1;

lb = [mn1 0 0 mn2 0 0 mn3 0 0];
gu = [mn1 1 1 mn2 1 .1 mn3 1 .1];
ub = [mn1 1 1 mn2 1 .1 mn3 1 .1];
inp = inp(:)';

fit = lsqcurvefit(fitfcn, gu, inx, inp, lb, ub);

figure, plot(inx, inp) , hold on, plot(inx, fitfcn(fit, inx)), 
plot(inx, gau(fit(1:3), inx))
plot(inx, gau(fit(4:6), inx))
plot(inx, gau(fit(7:9), inx))

