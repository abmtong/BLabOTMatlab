function [out, outsum] = eracorr(inx, Fs, sumtmax)

if nargin < 3
    sumtmax = 0.01;
end

if nargin < 2
    Fs = 4e3;
end

len = length(inx);
ot = xcorr(inx-mean(inx));
out = ot(len:end);

if nargout > 1
    fitfcn = @(x0,x) x0(1) * exp(-x0(2) * x) + x0(3);
    lsqopts = optimoptions('lsqcurvefit');
    lsqopts.Display = 'none';
    x = (0:len-1) / Fs;
    twin = x<sumtmax;
    x = x(twin);
    fit = lsqcurvefit(fitfcn, [out(1) 10/sumtmax 0], x, out(twin), [], [], lsqopts);
    outsum = fit(1)/fit(2);
end