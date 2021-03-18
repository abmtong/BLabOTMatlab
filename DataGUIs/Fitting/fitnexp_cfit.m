function [out, outraw] = fitnexp_cfit(xdata, n, verbose)
%Curve fitting. Cant get mle to work 'right'

%Fits 1-5 exponentials, stops according to AIC
if nargin < 2
    n=5; %Max exponentials to fit
end

if iscell(xdata)
    xdata = [xdata{:}];
end
if nargin < 3
    verbose = 1;
end

%Create containers
fts = cell(1,n);
cis = cell(1,n);
aics = zeros(1,n);
aics2 = zeros(1,n);

if verbose
    fg = figure;
end

%lsqcurvefit options. Make it a little more stringent, seems unnecessary but w/e
lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';
lsqopts.OptimalityTolerance = 1e-9;
lsqopts.FunctionTolerance = 1e-9;

xdata = sort(xdata, 'descend');
yy = (1:length(xdata)) / length(xdata);

ki = 1: round(length(yy)*.99);
yy = yy(ki);
xdata = xdata(ki);

for i = 1:n
    ned = nexpdist_cfit(i);
    %Make guess
    if i == 1 %Use gneeric 1exp guess (full occupancy, estimate rate with median)
        xg = [1, log(2)/median(xdata)];
    else %Add onto previous result with slower + less occupant ones
        xg = [fts{i-1} fts{i-1}(end-1:end)/4 ];
    end
    
    %Fit using lsqcurvefit
    [fts{i}, ~, rsd] = lsqcurvefit(ned.ccdf, xg, xdata, yy, ned.lb, ned.ub, lsqopts);
	
    %Fit using lsqcurvefit in logspace
%     [fts{i}, ~, ~] = lsqcurvefit(@(x0,x)ned.lccdf(x0,x), xg, xdata, log(yy), ned.lb, ned.ub, lsqopts);
%     rsd = yy - ned.lccdf(fts{i}, xdata); %Can't use log residual, need regular residual
        
    %Calculate logprob
    logprob = sum(log(ned.pdf(fts{i}, xdata)));
    
    %AIC for curvefitting = n log (var_rsd) + 2k. Use this instead of logprob [which should only be for mle?]
    aics(i) = 2*length(xg) + length(xdata) * log( var(rsd) );
    aics2(i) = n - logprob;
    
    %Plot
    if verbose
        subplot2([n 1], i);
        plot(xdata, yy, 'Color', .7 * [1 1 1])
        hold on
        plot(xdata, ned.ccdf(fts{i}, xdata));
        set(gca, 'YScale', 'log')
    end
    if i > 1
        %Break if AIC increases
        if aics(i) > aics(i-1)
            nfit = i-1;
            break
        else
            nfit = i;
        end
    end
    
end

if verbose
    ax = fg.Children;
    linkaxes(ax, 'xy')
    axis tight
    xlim([0 2])
end


%Return nfit's results
out.n = nfit;
out.ft = fts(nfit);
out.ci = cis(nfit);

outraw.n = n;
outraw.ft = fts;
outraw.ci = cis;
outraw.aic = aics;
outraw.aic2 = aics2;