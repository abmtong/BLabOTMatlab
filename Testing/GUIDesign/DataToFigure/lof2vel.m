function [ax, vpdff, x, fit, rawcon] = lof2vel(incropstr, inOpts)

if nargin < 1
    incropstr = '11';
end

%declare options:
%opts for @vdist
opts.sgp = {1 401}; %Savitsky Golay Params
opts.vbinsz = 2; %Velocity BIN SiZe
opts.Fs = 2500; %Frequency of Sampling
%opts for this fcn
opts.verbose = 1;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%loads crops by incropstr
rawcon = getFCs(incropstr);

%calculate velocity dist (filtered by sgolay)
[vpdf, x] = vdist(rawcon, opts);
x = -x*.34; %xform to positive velocity, nm

%fit two gaussians, taken from phagepause

%Fit vel pdf to two gaussians [fiddle with sgf filter width to make the peaks nice)
% Peaks are the paused and translocating sections
npdf = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3);
bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) ;
xg = [0 6 .2 33 6 .8];
lb = [0 0 0 0 0 0];
ub = [0 inf 1 inf inf 1];

%Fit using @lsqcurvefit
lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';
fit = lsqcurvefit(bigauss, xg, x, vpdf, lb, ub, lsqopts);
fp = bigauss(fit, x);

%assign, plot
if opts.verbose
    figure, plot(x, vpdf, 'o'), hold on, 
    plot(x, fp, 'LineWidth', 2, 'Color', 'k')
    plot(x, npdf(fit(1:3),x), ':', 'LineWidth', 1.5, 'Color', 'k')
    plot(x, npdf(fit(4:6),x), '--', 'LineWidth', 1, 'Color', 'k')
    line(fit(4) * [1 1], [0 max(fp)*2], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'k')
    fprintf('Speed %0.2f +- %0.2f nm/s, %0.2f pct paused\n', fit(4:5), fit(3))
end
%show no cmd line out if not assgnd
if nargout > 0
    if opts.verbose
        ax = gca;
    else
        ax = [];
    end
end