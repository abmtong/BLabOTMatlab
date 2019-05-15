function [fit, fitfcn, x, y] = fitexp(indat, verbose)
%Fits an exponential to the data inx using @lsqcurvefit
% The exponential has two parameters: mean and x-offset
%Try to shift data to positive beforehand, but algorithm is pretty good at handling weird offsets


if nargin < 1
    indat = exprnd(10,1,1e4) - 235;
%     inx = inx(inx > 3);
end


%make ccdf
x = sort(indat);
y = (1:length(x)) /length(x);

%fit to the ccdf
fitfcn = @(x0, x) 1-exp(-x0(1)\(x-x0(2)));
fit = lsqcurvefit(fitfcn, [mean(abs(x) ) , x(1)], x, y);

%plot result if just testing (no args)
if nargin < 1 || nargin > 1 && verbose
    figure, plot(x,y), hold on, plot(x, fitfcn(fit, x))
end