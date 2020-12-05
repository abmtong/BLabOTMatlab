function out = fitbiexp(dws, rng, method, verbose)

%Fit a bi-exponential over x-range rn

if nargin < 2
    rng = [0 inf];
end

if nargin < 3
    method = 1;
end

if nargin < 4
    verbose = 1;
end

switch method
    case 1 %Two independent exp
        fitfcn = @(x0,x) x0(1) * exp(-x0(2)*x) + x0(3) * exp(-x0(4)*x);
        xg = [1 20 1 5];
        lb = [0 0 0 0 ];
        ub = [1 inf 1 inf];
    case 2 %Sums to 1
        fitfcn = @(x0,x) x0(1) * exp(-x0(2)*x) + (1-x0(1)) * exp(-x0(3)*x);
        xg = [1 20 2];
        lb = [0 0 0];
        ub = [1 inf inf];
    case 3 %One exp
        fitfcn = @(x0,x) x0(1) * exp(-x0(2)*x);
        xg = [1 20];
        lb = [0 0];
        ub = [1 inf];
end

xx = sort(dws);
yy = 1-(0:length(dws)-1)/length(dws);

%Crop to rng
ki = xx >= rng(1) & xx <= rng(2);
xxc = xx(ki);
yyc = yy(ki);

%Fit in log-space
ft = lsqcurvefit(@(x0,x)log(fitfcn(x0,x)), xg, xxc, log(yyc), lb, ub, optimoptions('lsqcurvefit', 'Display', 'off'));
out.fitfcn = fitfcn;
out.ft = ft;
out.xl = rng;


%And plot
if verbose
    figure, semilogy(xx, yy, 'Color', [.7 .7 .7]);
    hold on
    % px = linspace(min(xxc), max(xxc), 1e3);
    px = linspace(min(xx), max(xx), 1e4);
    py = fitfcn(ft, px);
    plot(px,py);
    axis tight
    xlim(rng)
    switch method
        case 1
            pts = ft([2 4]).^-1;
            pct = ft([1 3]) / sum(ft([1 3]));
        case 2
            pts = ft([2 3]).^-1;
            pct = ft(1) + [0 -1];
        case 3
            pts = ft(2).^-1;
            pct = 1;
    end
    arrayfun(@(x,y) text(x, interp1(px, py, x), sprintf('%0.2f/s, %0.2f%%', x^-1,y*100)),pts, pct);
    xlabel('Time(s)')
    ylabel('CCDF(arb.)')
end





