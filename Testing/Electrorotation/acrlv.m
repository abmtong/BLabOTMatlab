function [out, integ] = acrlv(inx, acrlen)
%Mimics the acorr done in the instrument. Not perfect yet.

%Possible issues:
% Acorr numbers aren't exactly the same, not sure why. Math has been made equivalent, cropping should be the same
% Optimization procedure is not the same? Both should(?) use L-M but maybe with different starting no.s;
%  regardless, they should find the same minimum bc the optimization problem is 'simple enough' ?

len = length(inx);
wid = len - acrlen + 1;

out = zeros(1,acrlen);
tmpi = 1:wid;
for i = 1:acrlen
    out(i) = mean(inx(tmpi) .* inx((tmpi + i - 1)));
end

Fs = 4000;

%fit exponential if nargout > 1
if nargout > 1
    fitfcn = @(x0,x) x0(1) * exp(-x0(2) * x) + x0(3);
    lsqopts = optimoptions('lsqcurvefit');
    lsqopts.Display = 'none';
    x = (0:acrlen-1)/Fs;
    lb = [0   0  -inf];
    ub = [inf inf inf];
    gu = [out(1) 1/x(end) 0];
    fit = lsqcurvefit(fitfcn, gu, x, out, lb, ub, lsqopts);
    integ = fit(1)/fit(2);
end