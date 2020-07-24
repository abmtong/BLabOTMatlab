function [outg , outp, gamfun] = fitgamma(inx, iny, lb, ub)
%Fits a normalized gamma distribution to (x,y) using lsqcurvefit [not a MLE method like @fitdist would]

if nargin < 4
    ub = [inf inf];
end

if nargin < 3
    lb = [0 0];
end

%ga = [k, th]
gamfun = @(ga, x) x.^(ga(1)-1) .* exp(-x/ga(2)) / gamma(ga(1)) / ga(2)^ga(1);

%Generate guess
% gu = [1 .1];
[~, mi] = max(iny);
gu = [1, inx(mi)];

outg = lsqcurvefit(gamfun, gu, inx, iny, lb, ub, optimoptions('lsqcurvefit', 'Display', 'none'));
outp = gamfun(outg, inx);