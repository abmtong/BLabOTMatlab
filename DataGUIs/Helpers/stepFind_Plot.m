function stepFind_Plot(tr, st, inOpts)
%Plots traces and their staircases , as well as step dists + 
%Inputs are Traces, Step traces, and Options

opts.yspc = 30;
opts.ycent = 5000;
opts.fgnam = 'Plot Sfind';
opts.Fs = 1000;

if nargin > 2
    opts = handleOpts(opts, inOpts);
end

n = length(tr);


%Normalize start positions
y0 = cellfun(@(x) x(1), st);
dy = opts.yspc*(1:n) - y0 + opts.ycent;

fg = figure('Name', '%s %s', opts.fgnam, inputname(1));

%Plot traces
ax1 = subplot2(fg, [4 1], [1 2]);
hold(ax1, 'on')
%Make plot colors: rainbow starting at blue with period 10
cols =    arrayfun(@(x)hsv2rgb([mod(x,1)  1 .6]), 2/3 + (1:length(tr))/10 ,'Uni', 0);
colsraw = arrayfun(@(x)hsv2rgb([mod(x,1) .3 .8]), 2/3 + (1:length(tr))/10 ,'Uni', 0);
%Plot traces + staircases
cellfun(@(x,y,c)plot(x+y, 'Color', c), tr, num2cell(dy), colsraw)
cellfun(@(x,y,c)plot(x+y, 'Color', c), st, num2cell(dy), cols)

%Convert staircase to dwells + inds
[ind, mea] = cellfun(@tra2ind, tr, 'Un', 0);
dwells = cellfun(@diff, ind, 'Un', 0);
steps = cellfun(@diff, mea, 'Un', 0);
dwells = [dwells{:}]/opts.Fs;
steps = [steps{:}];
        
stepN = length(steps);
stepNp = length(steps(steps>0));
newP = normHist(steps, 0.25);


subplot2([4,1],3);
x = newP(:,1);
bary = newP(:,2);
bar(x,bary);

fitdata = steps(steps>0);
logndist = fitdist(fitdata', 'logn');
hold on
distx = x(x>0);
dataratio = length(fitdata)/length(steps);
disty = pdf(logndist, distx)*dataratio;
plot(distx, disty, 'LineWidth', 1)
[maxy, maxx] = max(disty);
normdist = fitdist(fitdata', 'normal');
text(distx(maxx)*1.75, maxy*.75, sprintf('Mode: %0.3f\nN: %d, N+: %d\nMu, Sig: %0.3f, %0.3f\nMean: %0.3f\nLogMean: %0.3f\nNormMean: %0.3f', exp(logndist.mu-logndist.sigma^2), stepN, stepNp, logndist.mu,logndist.sigma, exp(logndist.mu + logndist.sigma^2/2), exp(logndist.mu), normdist.mu))

%Calculate dwell histogram
[yy, xx] = nhistc(dwells, ceil(2*iqr(dwells)*numel(dwells)^(-1/3))); %Histogram bin size = ceil of F-D estimator
%Make sure there's enough bins, else redo with automatic bin size
if length(xx) < 5
    [yy, xx] = nhistc(dwells);
end
%X cutoff
prc = [0 95]; %Percentile cutoffs
xmn = prctile(dwells, prc(1));
xmx = prctile(dwells, prc(2));
%Make sure enough data falls within bounds; else dont crop
if sum(xx<=xmx & xx >= xmn) < 5
    xmx = inf;
    xmn = 0;
end
%Fit to gamma dist (k, th)
gamm   = @(x0,x) x0(3) * x.^(x0(1)-1) .* exp(-x/x0(2)) / gamma(x0(1)) /x0(2)^x0(1);
lb = [1 0 0];
ub = [inf inf 1];
gu = [4 .1/4 1]; %Guess k=4, mean = 0.1 = k*th
ft = lsqcurvefit(gamm, gu, xx(xx<=xmx & xx >= xmn), yy(xx<=xmx& xx >= xmn), lb, ub);
mn = mean(dwells(dwells<=xmx & dwells >= xmn));
sd = std(dwells(dwells<=xmx & dwells >= xmn));
%Fit with fitdist
gamdist = fitdist(dwells(:), 'gamma');
%And plot
subplot2([4,1],4), plot(xx,yy), hold on, plot(xx, gamm(ft, xx)), line( xmx*[1 1], ylim), line( xmn*[1 1], ylim)
plot(xx, pdf(gamdist, xx))
text( (ft(1)-1) * ft(2), max(yy), sprintf('Gamma with k = %0.2f, th = %0.5f, amp %0.3f', ft))
text( (ft(1)-1) * ft(2), max(yy)*.5,sprintf('Naive guess mean: %0.3f, sd: %0.3f, nmin: %0.2f\n', mn, sd, mn^2/sd^2))
text( (ft(1)-1) * ft(2), max(yy)*.1,sprintf('Fitdist k = %0.2f, th = %0.5f', gamdist.a, gamdist.b))
xlim([0 2*xmx])