function fit = assesspwd(inpwdx, inpwdy)

%fit to cosine, periodicity between 9-10

fitfcn = @(x0, x) x0(1) * cos( 2*pi*x /x0(2)) + x0(3) ;

fitregion = [1 10.5];
stind = find(inpwdx >= fitregion(1), 1);
stend = find(inpwdx <= fitregion(2), 1, 'last');
guess = [0.1 2 .6];
lb = [-1 1 0];
ub = [1 11 1];

x = inpwdx(stind:stend);
y = inpwdy(stind:stend);
opts = optimoptions('lsqcurvefit');
opts.Display = 'off';
fit = lsqcurvefit(fitfcn, guess, x, y, lb, ub);

figure, plot(x, y), hold on, plot(x, fitfcn(fit, x))