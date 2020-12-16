function out = fitnexp(xdata, inOpts)

%Fits 1-5 exponentials, stops according to AIC
n=5; %Max exponentials to fit, if >5 need to change @nexpdist

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

xdata = sort(xdata, 'descend');
xx = ((1:length(xdata))-1) / length(xdata);

for i = 1:n
    ned = nexpdist(i);
    %Make guesses: Mean, and then decaying means
    kg = log(2)/median(xdata);
    xg = [ 0.9.^(1:i); kg * (1:i) ];
    xg = xg(:)';
    [fts{i}, cis{i}] = mle(xdata, 'pdf', ned.pdf, 'start', xg, 'LowerBound', ned.lb, 'UpperBound', ned.ub);
    
    ftc = num2cell(fts{i});
    
    %Calculate logprob
    logprob = sum(log(ned.pdf(xdata, ftc{:})));
    
    %AIC = 2*n_parameters - 2*logprob ; we'll just ignore the 2's
    aics(i) = length(xg) - logprob;
    
    %Plot
    if verbose
        subplot2([n 1], i)
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
out.ft = fts(i);
out.ci = cis(i);

outraw.n = n;
outraw.ft = fts;
outraw.ci = cis;
outraw.aic = aics;