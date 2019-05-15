function [fit, fitfcn, x, y] = fitgam(indat, verbose)
%Fits gamma cdf to the data inx using @lsqcurvefit
% The exponential has two parameters: mean and x-offset
%Try to shift data to positive beforehand, but algorithm is pretty good at handling weird offsets

%gacdf = gammainc(k, x/th) / gamma(k); k shape th scale

if nargin < 1
    indat = exprnd(10,1,1e4) + exprnd(10,1,1e4)+ exprnd(10,1,1e4) + exprnd(10,1,1e4)...;
        +30;
%     inx = inx(inx > 3);
end


%make ccdf
x = sort(indat);
y = (1:length(x)) /length(x);

% y=y*.9+.1;

%fit to the cdf. gamma([shape, scale, x offset, y offset], x)
fitfcn = @(x0, x) gammainc( (x-x0(3))/x0(2), x0(1) ) * (1-x0(4)) + x0(4) ;
%gammainc is already normalized, so cdf of gamma is just gammainc

%guesses and bounds. Fails without lb of 0 (gammainc is undefined)
mn = mean(indat); %=k th
vr = var(indat); %= k th th
gu = [mn^2/vr, vr/mn 0 0];
% lb = [0 0 0 -inf];
% ub = [inf inf x(1) inf];
lb = [0 0 0 0];
ub = [inf inf 0 0];

fit = lsqcurvefit(fitfcn, gu, x, y, lb, ub);

%plot result if just testing (no args)
if nargin < 1 || nargin > 1 && verbose
    figure, plot(x,y), hold on, plot(x, fitfcn(fit, x))
end