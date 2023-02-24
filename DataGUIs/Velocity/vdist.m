function [ccts, xbins, cvel, cfilt, ccrop, fit] = vdist(c, inOpts)
%Calculates the velocity pdf of c by using sgolay filtering
%outputs: velocity pdf (normalized), velocity bins, trace -> velocity, ...
%  trace position filtered, trace position cropped (no filter)
%to e.g. get unnormalized counts, N = sum(cellfun(@length, cvel));

%Define default options
opts.sgp = {1 301}; %"Savitzky Golay Params"
opts.vbinsz = 2; %Velocity BIN SiZe
opts.Fs = 2500; %Frequency of Sampling
% Options for plotting, if requested
opts.verbose = 1;
opts.velmult = 1; %Velocity multiplier, set to -1 if negative velocity is forwards (for proper fitting)
opts.vfitlim = [-inf inf]; %Velocity to fit over
opts.fitmethod = 1;
opts.xlim = [-inf inf];
%Plot traces
opts.verboseplot = 0;
opts.verboseplotsd = 2;
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

%Apply transformation to velocity
cf2 = cf2 * opts.velmult;

%Bin values
[ccts, xbins] = nhistc(cf2, opts.vbinsz);

if opts.verbose || nargout > 5
%     %Transform velocity to positive, nm
%     xbins = xbins*opts.velmult;
%     ccts = ccts / abs(opts.velmult);
    %Velocity cutoff for fitting
    ki = false(size(xbins));
    for i = 1:length(opts.vfitlim)/2
        ki = ki | (xbins >= opts.vfitlim( (i-1)*2+1 ) & xbins <= opts.vfitlim( (i-1)*2+2 ));
    end
%     vmin = opts.vfitlim(1);
%     vmax = opts.vfitlim(2);
%     xf = xbins(xbins>vmin & xbins < vmax);
%     vf = ccts(xbins>vmin & xbins < vmax);
%     cfft = cf2(1:opts.sgp{1}:end);
%     cfft = cfft(cfft > vmin & cfft < vmax);
    
    xf = xbins(ki);
    vf = ccts(ki);
    cfft = cf2(1:opts.sgp{1}:end);
    cfft = cfft(ki);
    
    %Gaussians
    npdf = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3);
    bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) ;
    %Fit two gaussians, but with differing methods
    switch opts.fitmethod
        case 11 %For Phage, MLE
            %Fit two gaussians, one at zero, other positive
            sdg = std(cfft)/2;
            ampg = max(vf)*2.5/sdg/2;
            xg = [ sdg ampg prctile(cfft, 60) sdg ampg];
            lb = [ 0 0 0 0 0];
            ub = [ inf 1 inf inf 1];
            %Fit using MLE
            fit = mle(cfft, 'pdf', @(x,sd1,a1, m2,sd2,a2) bigauss([0 sd1 a1 m2 sd2 a2], x) / (a1 + a2), 'start', xg,  'LowerBound', lb, 'UpperBound', ub);
%             fit = lsqcurvefit(bigauss, xg, xf, vf, lb, ub, optimoptions('lsqcurvefit', 'Display', 'none'));
            fit = [0 fit]; %add set 0
            %Normalize heights
            fit([3 6]) = fit([3 6])/sum(fit([3 6]));
        case 13 %For Phage, MLE
            %Fit two gaussians, one at zero, other positive
            sdg = std(cfft)/2;
            ampg = max(vf)*2.5/sdg/2;
            xg = [0 sdg ampg prctile(cfft, 60) sdg ampg];
            lb = [-inf 0 0 0 0 0];
            ub = [inf inf 1 inf inf 1];
            %Fit using MLE
            fit = mle(cfft, 'pdf', @(x,m1,sd1,a1, m2,sd2,a2) bigauss([m1 sd1 a1 m2 sd2 a2], x) / (a1 + a2), 'start', xg,  'LowerBound', lb, 'UpperBound', ub);
%             fit = lsqcurvefit(bigauss, xg, xf, vf, lb, ub, optimoptions('lsqcurvefit', 'Display', 'none'));
            %Normalize heights
            fit([3 6]) = fit([3 6])/sum(fit([3 6]));
        case 1 %For Phage
            %Fit two gaussians, one at zero, other positive
            sdg = std(cf2, 'omitnan')/2;
            ampg = max(vf, [], 'omitnan')*2.5/sdg/2;
            xg = [0 sdg ampg prctile(cf2, 60) sdg ampg];
            lb = [0 0 0 0 0 0];
            ub = [0 inf 1 inf inf 1];
            %Fit using @lsqcurvefit
            fit = lsqcurvefit(bigauss, xg, xf, vf, lb, ub, optimoptions('lsqcurvefit', 'Display', 'none'));
        case 3 %For Phage
            %Fit two gaussians [no restrictions]
            sdg = std(cf2)/2;
            ampg = max(vf)*2.5/sdg/2;
            xg = [0 sdg ampg prctile(cf2, 60) sdg ampg];
            lb = [-inf 0 0 0 0 0];
            ub = [inf inf 1 inf inf 1];
            %Fit using @lsqcurvefit
            fit = lsqcurvefit(bigauss, xg, xf, vf, lb, ub, optimoptions('lsqcurvefit', 'Display', 'none'));
        case 2 %For polymerase, like Ronen
            %Fit one gaussian at 0 to negative data, then one to the rest. For polymerase
            xfn = xf(xf <= 0);
            vfn = vf(xf <= 0);
            xg = [0 6 .2];
            lb = [0 0 0];
            ub = [0 inf 1];
            fit1 = lsqcurvefit(npdf, xg, xfn, vfn, lb, ub, optimoptions('lsqcurvefit', 'Display', 'none'));
            vfs = vf - npdf(fit1, xf);
            xg2 = [33 6 .8];
            lb2 = [0 0 0];
            ub2 = [inf inf 1];
            fit2 = lsqcurvefit(npdf, xg2, xf, vfs, lb2, ub2, optimoptions('lsqcurvefit', 'Display', 'none'));
            fit = [fit1 fit2];
        otherwise
    end
    fp = bigauss(fit, xbins);
    
    %plot
    if opts.verbose
        figure('Name', sprintf('vdist %s: Speed %0.2f +- %0.2f (%0.2f SEM) nm/s, (%0.2f,%0.2f) pct (tloc,paused)\n', inputname(1), fit(4:5), fit(5)/ sqrt(fit(6)*sum(cellfun(@length, cvel))/opts.sgp{2}), 100*fit(6), 100*fit(3)))
        bar(xbins, ccts, 'FaceColor', [0 1 1], 'EdgeColor', 'none'), hold on
        plot(xbins, fp, 'LineWidth', 2, 'Color', 'k')
        plot(xbins, npdf(fit(1:3),xbins), ':', 'LineWidth', 1.5, 'Color', 'k')
        plot(xbins, npdf(fit(4:6),xbins), '--', 'LineWidth', 1, 'Color', 'k')
        line(fit(4) * [1 1], [0 max(fp)*2], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'k')
        %N for SEM purposes here is Ntot * pct / framelen, i.e. framelen pts become one [works for order 0 or 1, higher order = 'less N']
        %  we plot all the data to make the histogram smoother, but for stats use the decimated data
        xlim(opts.xlim)
    end
    
    if opts.verboseplot
        vthr = fit(2)*opts.verboseplotsd;
        figure('Name', sprintf('vdistplot %s: Speed %0.2f +- %0.2f (%0.2f SEM) nm/s, (%0.2f,%0.2f) pct (tloc,paused)\n', inputname(1), fit(4:5), fit(5)/ sqrt(fit(6)*sum(cellfun(@length, cvel))/opts.sgp{2}), 100*fit(6), 100*fit(3)))
        hold on
        cellfun(@(x,y) surface([1:length(x); 1:length(x)]/opts.Fs, [x;x], double([y;y]>vthr), 'EdgeColor', 'interp', 'LineWidth', 1), cfilt, cvel);
        %Set a good two-color colormap
        colormap winter
    end
end