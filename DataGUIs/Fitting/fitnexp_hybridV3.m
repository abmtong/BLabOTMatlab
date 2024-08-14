function [out, outraw] = fitnexp_hybridV3(xdata, inOpts)
%Hybrid: Curve fitting and MLE
%V3 in progress: ??? fit a=2 Gams ?

%NOW skips fitting 1 exp since for sum-of-exps it can too easily zero out prob and error

opts.minn = 2; %Min exps to fit, use 2 for very long tails that might error with =1
opts.n = 5; %Max exponentials to fit, if AIC minimum is not found
opts.verbose = 1; %Verbose (plot)
opts.xrange = [0 inf]; %Crop xdata, exclude from CCDF y
opts.xrangefit = [0 inf]; %Crop xdata, include in CCDF y
opts.prcmax = 100; %Percentile, kept in CCDF y 

opts.fitlast = 1; %Fit the last k separately?
opts.fitlastxmin = 3; %Fit x>k data to 1exp and use that for MLE CI

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

n = opts.n;

%Concatenate data, if cell
if iscell(xdata)
    xdata = [xdata{:}];
end

%Crop by xrange - to remove 'outliers' eg super-short steps or unfittable pauses
xdata = xdata( xdata > opts.xrange(1) & xdata < opts.xrange(2));

%MLE fit options
mleopts = statset('MaxFunEvals', 1e6, 'MaxIter', 1e6);

%Generate CCDF
ccy = (length(xdata):-1:1)/length(xdata);
ccyl = log(ccy);
ccx = sort(xdata);

%Crop by xrangefit/prc - here it also affects the Y-axis of ccy, so just for certain unfittable dwells
ki = ccx > opts.xrangefit(1) & ccx < opts.xrangefit(2) & ccx < prctile(ccx, opts.prcmax);
ccx = ccx(ki);
ccy = ccy(ki);
ccyl = ccyl(ki);

%Initial guess. Choosing something to guarantee no underflow
% ftg = [1 1/prctile(xdata, 100/exp(1))]; %Actual guess

%Fit last tail if asked
if opts.fitlast
    xlast = ccx( ccx > opts.fitlastxmin );
    %If there's no data, just skip
    if isempty(xlast)
        opts.fitlast = 0;
    end
    
    %MLE fit to 1exp
    [klast, klastci] = mle(xlast, 'pdf', @(x,k) k*exp(-k*x), 'start', 1/median(xlast),'LowerBound', 0, 'UpperBound', inf);
    klastci = klastci(2)-klast(1);
    
    %And then set this k as the last k in the loop, and hijack the CI calculation
end

%Guess for mu if this was 1exp
muguess = 1/prctile(ccx, 100/exp(1));
%Choose also a small k to make sure there's no underflow
upguess = min(muguess/10, 1/max(ccx));
switch opts.minn
    case 1 %1exp, choose to avoid underflow
        ftg = [1 upguess];
    case 2 %2exp, real guess + avoid underflow
        ftg = [1 muguess 1 upguess];
    case 3 %3exp, real guess + twice + avoid underflow
        ftg = [1 muguess 1 muguess/2 1 upguess];
        %Should write something to generate good guesses, eg percentile-based
    otherwise
        error('Invalid min_n of %d', opts.minn)
end
aic = inf;

%Output containers
cfits = cell(1,n);
cfcis = cell(1,n);
mfits = cell(1,n);
mfcis = cell(1,n);
aics = nan(1,n);
aicscf = nan(1,n);
%Distribution funciton handles, for plotting if verbose
cfh = cell(1,n);
mfh = cell(1,n);

for i = opts.minn:n
    %Try fitting i exponentials
    
    %First curve fit (logspace)
    
    ecf = nexpdist_cfit(i);
    cfh{i} = ecf;
    [ftc, ~, rsd, ~, ~, ~, jac] = lsqcurvefit(@(x0,x)log(ecf.ccdf(x0,x)), ftg, ccx, ccyl, ecf.lb, ecf.ub, optimoptions('lsqcurvefit', 'Display', 'none'));
    cfits{i} = ftc;
    %And CIs
    ftcci = nlparci(ftc, rsd, 'jacobian', jac);
    ftcci = ftcci(:,2)' - ftc;
    cfcis{i} = ftcci;
    
    %AIC for curvefitting = 2k + n log (var_rsd). Do on lcdf since that's what we're fitting to
    aicscf(i) = 2*length(ftg) + length(ccx) * log( var(rsd) );
    
    %Use this result to MLE fit
    mcf = nexpdist(i,2); %With a1
    mfh{i} = nexpdist(i,1); %Without a1
    %Curve fitting is in logspace, convert amplitudes to linear (not exactly the same, but better than not converting?)
    mlgu = ftc; 
    mlgu(1:2:end) = exp(mlgu(1:2:end));
    %Normalize a's to a1, remove 
    mlgu(1:2:end) = mlgu(1:2:end)/mlgu(1);
    mlgu = mlgu(2:end);
    lb = mcf.lb;
    ub = mcf.ub;
    
    %Handle fitlast exp
    if opts.fitlast
        %Set the guess, lb, ub
        mlgu(end) = klast;
        lb(end) = klast;
        ub(end) = klast;
    end
    
    %And fit
    [ftm, ftmci] = mle(ccx, 'pdf', mcf.pdf, 'start', mlgu, 'LowerBound', lb, 'UpperBound', ub, 'Options', mleopts);
    %Take average ci (they should be even-sided, anyway?)
    ftmci = diff(ftmci, 1, 1)/2;
    %Save, add back a1
    mfits{i} = [1 ftm];
    if i > 1
        mfcis{i} = [sqrt(sum(ftmci(2:2:end).^2)) ftmci]; %Error on a1 propogate from others (sum ai = 1)
    else
        mfcis{i} = [0 ftmci];
    end
    
    %Handle fitlast exp
    if opts.fitlast
        %Set the guess, lb, ub
        mfcis{i}(end) = klastci;
    end
    
    
    %Check for end: AIC (= k - logprob) increases
    mcfcell = num2cell(ftm);
    aicnew = 2*i - sum(log(mcf.pdf(ccx, mcfcell{:})));
    aics(i) = aicnew;
    if aicnew > aic && opts.verbose ~= 2
        optiter = i-1;
        break
    end
    
    %Update
    aic = aicnew;
    ftg = [mfits{i} mfits{i}(end-1:end) * 1/3];
    
    if i == n
        optiter = n;
        fprintf('Max exponentials fit and AIC not exceeded\n')
    end
end

%Assemble outputs
out = mfits{optiter};
outraw.cfits = cfits;
outraw.cfcis = cfcis;
outraw.mfits = mfits;
outraw.mfcis = mfcis;
outraw.aics = aics;
outraw.aicscf = aicscf;

%Plot if asked
if opts.verbose
    fg = figure;
    for j = i:-1:opts.minn
        %Plot curve fit results on left
        ax(j,1) = subplot2(fg, [i 2], j);
        hold(ax(j,1), 'on')
        plot(ax(j,1), ccx, ccy, 'o', 'Color', [.7 .7 .7])
        if isempty(cfits{j})
            continue
        end
        plot(ax(j,1), ccx, cfh{j}.ccdf(cfits{j}, ccx), 'Color', 'b')
        set(ax(j,1), 'YScale', 'log')
        etxt = sprintf('[%0.3g, %0.3g]\n', cfits{j});
        text(ax(j,1), 0, 1, sprintf('AIC: %0.2f\n %s', aicscf(j) - min(aicscf), etxt), 'VerticalAlignment', 'top')
        
        %And MLE results on right
        ax(j,2) = subplot2(fg, [i 2], j+i);
        hold(ax(j,2), 'on')
        plot(ax(j,2), ccx, ccy, 'o', 'Color', [.7 .7 .7])
        mcfcell = num2cell(mfits{j});
        mley = mfh{j}.cdf(ccx, mcfcell{:});
        plot(ax(j,2), ccx, mley, 'Color', 'g')
        set(ax(j,2), 'YScale', 'log')
        etxt = sprintf('[%0.3g, %0.3g]\n', mfits{j});
        text(ax(j,2), 0, 1, sprintf('AIC: %0.2f\n %s', aics(j)- min(aics), etxt), 'VerticalAlignment', 'top')
    end
    linkaxes(ax, 'xy')
    axis(ax(end), 'tight')
end
end
