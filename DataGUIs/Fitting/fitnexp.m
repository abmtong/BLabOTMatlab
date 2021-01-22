function [out, outraw] = fitnexp(xdata, n)

%Fits 1-5 exponentials, stops according to AIC
if nargin < 2
    n=5; %Max exponentials to fit, if >5 need to change @nexpdist
end

if iscell(xdata)
    xdata = [xdata{:}];
end
verbose = 1;
%Create containers
fts = cell(1,n);
cis = cell(1,n);
aics = zeros(1,n);

if verbose
    fg = figure;
end

%MLE options
mleopts = statset;
mleopts.MaxFunEvals = 1e12;

xdata = sort(xdata, 'descend');
xx = ((1:length(xdata))-1) / length(xdata);

for i = 1:n
    ned = nexpdist(i);
    %Make guess
    if i == 1 %Use gneeric 1exp guess (full occupancy, estimate rate with median)
        xg = [1, log(2)/median(xdata)];
    else %Add onto previous result with slower + less occupant ones
        xg = [fts{i-1} fts{i-1}(end-1:end)/4 ];
    end
    [ft, cis{i}] = mle(xdata, 'pdf', ned.pdf, 'start', xg, 'LowerBound', ned.lb, 'UpperBound', ned.ub);
    
    %Normalize amts
    ft(1:2:end) = ft(1:2:end)/sum(ft(1:2:end));
    fts{i} = ft;
    
    ftc = num2cell(fts{i});
    
    %Calculate logprob
    logprob = sum(log(ned.pdf(xdata, ftc{:})));
    
    %AIC = 2*n_parameters - 2*logprob ; we'll just ignore the 2's
    aics(i) = length(xg) - logprob;
    
    %Plot
    if verbose
        subplot2([n 1], i);
        plot(xdata, xx, 'Color', .7 * [1 1 1])
        hold on
        plot(xdata, ned.cdf(xdata, ftc{:}));
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