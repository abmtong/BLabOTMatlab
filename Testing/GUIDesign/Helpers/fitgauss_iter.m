function [newfit, gauss] = fitgauss_iter(inx, iny, sdrange)
%Fits a gaussian to a given pdf (inx, iny)
%Made to ignore to smaller peaks, should find the largest one

if ~isa(inx, 'double')
    inx = double(inx);
end
if ~isa(iny, 'double')
    iny = double(iny);
end

%Default sdrange is +-2sd
if nargin < 3
    sdrange = [-2 2]; %only fit points within this range. Default +- 2sd, but can do more/less/asymmetric
end


gauss = @(x0, x) exp(-0.5 * ((x - x0(1))./x0(2)).^2) ./ (sqrt(2*pi) .* x0(2)) * x0(3);
lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';

lb = [-inf min(abs(diff(inx))) 0];
ub = [inf inf length(inx)];
%make guess of mean, sd, max. dont actually guess sd, just use range(x) bc we want this to be like and upper bound
curfit = [mean(sum(inx.*iny)/sum(iny)), range(inx)/3, max(iny)];

%do up to n iter.s (stop if it doesn't change)
n=10;
%take up to 1s
tm = 1;

st = tic;

for i = 1:n
    %restrict x to be within x+sdrange*sd
    ki = (inx > curfit(1) + sdrange(1) * curfit(2) & inx < curfit(1) + sdrange(2) * curfit(2));
    newfit = lsqcurvefit(gauss, curfit, inx(ki), iny(ki), lb, ub, lsqopts);
    if isequal(newfit, curfit)
        break
    end
    if toc(st) > tm
        fprintf('Max time for %s exceeded, exiting\n', mfilename)
        break
    end
    if i==n
        fprintf('Max iters for %s exceeded, exiting\n', mfilename)
    end
    curfit = newfit;
end


