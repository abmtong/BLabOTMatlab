function [outg , outp] = fitgamma(inx, iny)
%fits a gamma distribution with cutoff at last inx

%ga = k, th
gwco = @(ga, x) x.^(ga(1)-1) .* exp(-x/ga(2)) / gamma(ga(1)) / ga(2)^ga(1);

outg = lsqcurvefit(gwco, [1 .1], inx, iny);
outp = gwco(outg, inx);