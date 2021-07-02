function [out, outraw] = fitngam_hybrid(xdata, n, shape, verbose)
%Hybrid: Curve fitting and MLE

%Edit of fitnexp_cfit to work with a gamma with a set shape
%Can maybe replace fitnexp(varargin) with fitngam(varargin, 1), output seems to match

%Fits up to n exponentials, stops according to AIC
if nargin < 2
    n=5; %Max exponentials to fit, if AIC minimum is not found
end

%Concatenate data, if cell
if iscell(xdata)
    xdata = [xdata{:}];
end

%Default verbose flag
if nargin < 4
    verbose = 1;
end

%MLE fit options
mleopts = statset('MaxFunEvals', 1e6, 'MaxIter', 1e6);

%Generate CDF
ccy = (length(xdata):-1:1)/length(xdata);
ccyl = log(ccy);
ccx = sort(xdata);

%Initial guess. Choosing something to guarantee no underflow
% ftg = [1 1/prctile(xdata, 100/exp(1))]; %Actual guess
ftg = [1 1/max(ccx)]; %Need to be careful about initial guess [so cdf doesn't underflow], or redefine as lcdf [hard for a sum]
aic = inf;

%Output containers
cfits = cell(1,n);
mfits = cell(1,n);
mfcis = cell(1,n);
aics = nan(1,n);
aicscf = nan(1,n);
%Distribution funciton handles, for plotting if verbose
cfh = cell(1,n);
mfh = cell(1,n);

for i = 1:n
    %Try fitting i gammas
    
    %First curve fit (logspace)
    ecf = ngamdist_cfit(i, shape);
    cfh{i} = ecf;
    [ftc, ~, rsd] = lsqcurvefit(@(x0,x)log(ecf.ccdf(x0,x)), ftg, ccx, ccyl, ecf.lb, ecf.ub, optimoptions('lsqcurvefit', 'Display', 'none'));
    cfits{i} = ftc;
    %AIC for curvefitting = 2k + n log (var_rsd). Do on lcdf since that's what we're fitting to
    aicscf(i) = 2*length(ftg) + length(xdata) * log( var(rsd) );
    
    %Use this result to MLE fit
    mcf = ngamdist(i,shape,2); %With a1
    mfh{i} = ngamdist(i,shape,1); %Without a1
    %Curve fitting is in logspace, convert amplitudes to linear (not exactly the same, but better than not converting?)
    mlgu = ftc; 
    mlgu(1:2:end) = exp(mlgu(1:2:end));
    %Normalize a's to a1, remove 
    mlgu(1:2:end) = mlgu(1:2:end)/mlgu(1);
    mlgu = mlgu(2:end);
    %And fit
    [ftm, ftmci] = mle(xdata, 'pdf', mcf.pdf, 'start', mlgu, 'LowerBound', mcf.lb, 'UpperBound', mcf.ub, 'Options', mleopts);
    %Take average ci (they should be even-sided, anyway?)
    ftmci = diff(ftmci, 1, 1)/2;
    %Save, add back a1
    mfits{i} = [1 ftm];
    if i > 1
        mfcis{i} = [sqrt(sum(ftmci(2:2:end).^2)) ftmci]; %Error on a1 propogate from others (sum ai = 1)
    else
        mfcis{i} = [0 ftmci];
    end
    
    %Check for end: AIC (= k - logprob) increases
    mcfcell = num2cell(ftm);
    aicnew = 2*i - sum(log(mcf.pdf(xdata, mcfcell{:})));
    aics(i) = aicnew;
    if aicnew > aic && verbose ~= 2
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
outraw.mfits = mfits;
outraw.mfcis = mfcis;
outraw.aics = aics;
outraw.aicscf = aicscf;

%Plot if asked
if verbose
    fg = figure;
    for j = i:-1:1
        %Plot curve fit results on left
        ax(j,1) = subplot2(fg, [i 2], j);
        hold(ax(j,1), 'on')
        plot(ax(j,1), ccx, (ccy), 'o', 'Color', [.7 .7 .7]) %Change from cdf to ccdf, for plotting (to better show small tails)
        plot(ax(j,1), ccx, (cfh{j}.ccdf(cfits{j}, ccx)), 'Color', 'b') %Sum a_i ~=1 for cfit, so subtract from sum a_i instead
        set(ax(j,1), 'YScale', 'log')
        etxt = sprintf('[%0.3g, %0.3g]\n', cfits{j});
        text(ax(j,1), 0, 1, sprintf('AIC: %0.2f\n %s', aicscf(j) - min(aicscf), etxt), 'VerticalAlignment', 'top')
        
        %And MLE results on right
        ax(j,2) = subplot2(fg, [i 2], j+i);
        hold(ax(j,2), 'on')
        plot(ax(j,2), ccx, (ccy), 'o', 'Color', [.7 .7 .7])
        mcfcell = num2cell(mfits{j});
        mley = 1-(mfh{j}.cdf(ccx, mcfcell{:}));
        plot(ax(j,2), ccx, mley, 'Color', 'g')
        set(ax(j,2), 'YScale', 'log')
        etxt = sprintf('[%0.3g, %0.3g]\n', mfits{j});
        text(ax(j,2), 0, 1, sprintf('AIC: %0.2f\n %s', aics(j)- min(aics), etxt), 'VerticalAlignment', 'top')
    end
    linkaxes(ax, 'xy')
    axis(ax(end), 'tight')
end
end
