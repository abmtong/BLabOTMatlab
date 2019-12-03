function [ccts, xbins, cvel, cfilt, ccrop] = vdist(c, inOpts)
%Calculates the velocity pdf of c by using sgolay filtering

%outputs: velocity pdf (normalized), velocity bins, trace -> velocity, ...
%  trace position filtered, trace position cropped (no filter)
%to e.g. get unnormalized counts, N = sum(cellfun(@length, cvel));

%Define default options
opts.sgp = {1 301}; %"Savitsky Golay Params"
opts.vbinsz = 2; %Velocity BIN SiZe
opts.Fs = 2500; %Frequency of Sampling

if nargin >= 2
    opts = handleOpts(opts, inOpts);
end

if ~iscell(c)
    c = {c};
end

%Apply @sgolaydiff to input
[cvel, cfilt, ccrop] = cellfun(@(x)sgolaydiff(x, opts.sgp), c, 'uni', 0);
%Convert velocity from /pt to /s
cvel = cellfun(@(x) double(x)*opts.Fs, cvel, 'Uni', 0); 
%Concatenate velocities
cf2 = [cvel{:}];

%Bin values
[ccts, xbins] = nhistc(cf2, opts.vbinsz);

if nargout < 1 %Plot instead of output
    %Transform velocity to positive, nm
    xbins = -xbins*.34;
    ccts = ccts / .34;
    %Velocity cutoff for fitting
    vmin = 0;
    vmax = 100;
    xf = xbins(xbins>vmin & xbins < vmax);
    vf = ccts(xbins>vmin & xbins < vmax);
    
    %Fit two gaussians, code taken from phagepause
    npdf = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3);
    bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) ;
    xg = [0 6 .2 33 6 .8];
    lb = [0 0 0 0 0 0];
    ub = [0 inf 1 inf inf 1];
    
    %Fit using @lsqcurvefit
    fit = lsqcurvefit(bigauss, xg, xf, vf, lb, ub, optimoptions('lsqcurvefit', 'Display', 'none'));
    fp = bigauss(fit, xbins);
    
    %plot
    figure('Name', sprintf('vdist %s: Speed %0.2f +- %0.2f (%0.2f SEM) nm/s, (%0.2f,%0.2f) pct (tloc,paused)\n', inputname(1), fit(4:5), fit(5)/ sqrt(fit(6)*sum(cellfun(@length, cvel))/opts.sgp{2}), 100*fit(6), 100*fit(3)))
    bar(xbins, ccts), hold on
    plot(xbins, fp, 'LineWidth', 2, 'Color', 'k')
    plot(xbins, npdf(fit(1:3),xbins), ':', 'LineWidth', 1.5, 'Color', 'k')
    plot(xbins, npdf(fit(4:6),xbins), '--', 'LineWidth', 1, 'Color', 'k')
    line(fit(4) * [1 1], [0 max(fp)*2], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'k')
    %N for SEM purposes here is Ntot * pct / framelen, i.e. framelen pts become one [works for order 0 or 1, higher order = 'less N']
    %  we plot all the data to make the histogram smoother, but for stats use the decimated data
    xlim([-100 100])
    clear ccts
end