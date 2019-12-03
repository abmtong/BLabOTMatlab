function [outInd, outMea, outTra, steps, dwells] = BatchKV(inContour, inPenalty, maxSteps, verbose, validate)
%Does batch operation using AFindSteps. Same inputs as @AFindStepsV5, except the first argument is a cell array of contours.
%   Plots a results summary with a step size distribution, disable with verbose = 0.
%   input: validate = 1 makes @kvxfit run on the found steps.
%See documentation in @AFindStepsV5, @kvxfit

if nargin < 5 || isempty(validate)
    validate = 0;
end
if nargin < 4 || isempty(verbose)
    verbose = 1;
end
if nargin < 3 || isempty(maxSteps)
    maxSteps = [];
end
if nargin < 2 || isempty(inPenalty)
    inPenalty = [];
end
if ~iscell(inContour)
    inContour = {inContour};
end

%Pass inPenalty as single to instead use it as a penalty factor (or however @AFindSteps handles singles)

startT = tic;
hei = length(inContour);
conshft = cell(1,hei);
%Shift inContour so plot is nice (magnitude of inContour is irrelevant)
for i = 1:hei
    conshft{i} = 9e3 - inContour{i}(1) - i*20;
%     inContour{i} = inContour{i} + conshft(i);
end

%Progress Meter
dash = '-';
fprintf('[%s]\n',dash(ones(1,length(inContour))))
%Do stepfinding - prints a '|' for each trace done
fprintf('[\n')
%K-V is fast enough that ppool is usually unnecessary (Time saved < ppool start time) - only parfor if a ppool is already up
ppool = gcp('nocreate');
if isempty(ppool)
    [outInd, outMea, outTra] = cellfun(@(x)AFindStepsV5(x, inPenalty, maxSteps, 3), inContour, 'Uni', 0);
else
    parfor i = 1:hei
        [outInd{i}, outMea{i}, outTra{i}] = AFindStepsV5(inContour{i}, inPenalty, maxSteps, 3);
    end
end
fprintf('\b]\n')

%Calculate step size histogram
if validate
    [~, steps, dwells] = cellfun(@kvxfit, outInd, outMea, inContour, 'Un', 0);
    steps = cellfun(@(x)-x, steps, 'un',0);
else
    steps = cellfun(@(x)-diff(x), outMea,'Uni',0);
    dwells = cellfun(@(x)diff(x), outInd, 'Uni',0);
    dwells = cellfun(@(x)x(2:end-1), dwells, 'Uni',0);
end
steps = [steps{:}];
dwells = [dwells{:}];
Fs = 2.5e3; %hard-coded Fs
dwells = dwells / Fs;

if verbose
    stepN = length(steps);
    stepNp = length(steps(steps>0));
    newP = normHist(steps, 0.25);
    
    figure('Name',sprintf('%s {%s [%s]}', mfilename, inputname(1), sprintf('%0.3f ',inPenalty)));
    %Plot step size distribution
    subplot(3,1,1);
    hold on
    %make plot colors: rainbow starting at blue with period 10
    cols =    arrayfun(@(x)hsv2rgb([mod(x,1)  1 .6]), 2/3 + (1:length(inContour))/10 ,'Uni', 0);
    colsraw = arrayfun(@(x)hsv2rgb([mod(x,1) .3 .8]), 2/3 + (1:length(inContour))/10 ,'Uni', 0);
    
    cellfun(@(x,y,c)plot(x+y, 'Color', c), inContour, conshft, colsraw)
    cellfun(@(x,y,c)plot(x+y, 'Color', c), outTra, conshft, cols)
    
    subplot(3,1,2);
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
    [yy, xx] = nhistc(dwells, 10/Fs); %Bin size * Fs should be integer
    %X cutoff
    prc = 5 * [0 1]; %Percentile cutoff
    xmn = prctile(dwells, prc(1));
    xmx = prctile(dwells, 100-prc(2));
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
    subplot(3,1,3), plot(xx,yy), hold on, plot(xx, gamm(ft, xx)), line( xmx*[1 1], ylim), line( xmn*[1 1], ylim)
    plot(xx, pdf(gamdist, xx))
    text( (ft(1)-1) * ft(2), max(yy), sprintf('Gamma with k = %0.2f, th = %0.5f, amp %0.3f', ft))
    text( (ft(1)-1) * ft(2), max(yy)*.5,sprintf('Naive guess mean: %0.3f, sd: %0.3f, nmin: %0.2f\n', mn, sd, mn^2/sd^2))
    text( (ft(1)-1) * ft(2), max(yy)*.1,sprintf('Fitdist k = %0.2f, th = %0.5f', gamdist.a, gamdist.b))
    xlim([0 2*xmx])
end
fprintf('BatchKV took %0.2fs\n', toc(startT))