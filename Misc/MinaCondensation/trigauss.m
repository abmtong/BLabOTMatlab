function [out, outraw] = trigauss(x, y, typ)



trigauss = @(x0,x) x0(1)*normpdf(x, x0(2), x0(3)) + x0(4)*normpdf(x, x0(5), x0(6)) + x0(7)*normpdf(x, x0(8), x0(9)) ;

%Guess: amp mean sd
xg = [ 1 0 500     ...
       0.1 -500 500      ...
       0.1 500 500];
xg = xg(:)';
lb = [0 0 0   0 -inf 0   0 0 0];
ub = [inf 0 inf   inf 0 inf  inf inf inf];

out = lsqcurvefit(trigauss, xg, x, y, lb, ub);

outraw.fn = trigauss;
outraw.x = x;
outraw.y = y;
outraw.yfit = trigauss(out, x);
outraw.ft = out;
outraw.gau = @(x0,x) x0(1)*normpdf(x, x0(2), x0(3));