function [outInd, outMea, outTra, stepDist] = BatchKV(inContour, inPenalty, maxSteps, verbose)
%inContour now a cell array of contours

if nargin < 4 || isempty(verbose)
    verbose = 1;
end
if nargin < 3 || isempty(maxSteps)
    maxSteps = [];
end
if nargin < 2 || isempty(inPenalty)
    inPenalty = [];
end

%Pass inNoise as single to instead use it as a penalty factor (or however @AFindSteps handles singles)

startT = tic;
hei = length(inContour);
%Shift inContour so plot is nice (magnitude of inContour is irrelevant)
for i = 1:hei
    inContour{i} = 9e3+ inContour{i} - inContour{i}(1) - i*20;
end

%Progress Meter
dash = '-';
fprintf('[%s]\n',dash(ones(1,length(inContour))))
%Do stepfinding - prints a '|' for each trace done
fprintf('[\n')
%K-V is fast enough that ppool is usually unnecessary (Time saved < ppool start time) - only parfor if a ppool is already up
ppool = gcp('nocreate');
if isempty(ppool)
    [outInd, outMea, outTra] = cellfun(@(x)AFindStepsV4(x, inPenalty, maxSteps, 3), inContour, 'Uni', 0);
else
    parfor i = 1:hei
        [outInd{i}, outMea{i}, outTra{i}] = AFindStepsV4(inContour{i}, inPenalty, maxSteps, 3);
    end
end
fprintf('\b]\n')

%Calculate step size histogram
stepDist = cellfun(@(x)-diff(x), outMea,'Uni',0);
stepDist = [stepDist{:}];
stepN = length(stepDist);
stepNp = length(stepDist(stepDist>0));
newP = normHist(stepDist, 0.25);

if verbose
    figure('Name',sprintf('%s {%s [%s]}', mfilename, inputname(1), sprintf('%0.3f ',inPenalty)));
    %Plot step size distribution
    subplot(3,1,[1 2]);
    hold on
    cellfun(@(x)plot(x,'Color',[.7 .7 .7]), inContour)
    cellfun(@plot, outTra)
    
    subplot(3,1,3);
    x = newP(:,1);
    bary = newP(:,2);
    bar(x,bary);
    
    fitdata = stepDist(stepDist>0);
    logndist = fitdist(fitdata', 'logn');
    hold on
    distx = x(x>0);
    dataratio = length(fitdata)/length(stepDist);
    disty = pdf(logndist, distx)*dataratio;
    plot(distx, disty, 'LineWidth', 1)
    [maxy, maxx] = max(disty);
    normdist = fitdist(fitdata', 'normal');
    text(distx(maxx)*1.75, maxy*.75, sprintf('Mode: %0.3f\nN: %d, N+: %d\nMu, Sig: %0.3f, %0.3f\nMean: %0.3f\nLogMean: %0.3f\nNormMean: %0.3f', exp(logndist.mu-logndist.sigma^2), stepN, stepNp, logndist.mu,logndist.sigma, exp(logndist.mu + logndist.sigma^2/2), exp(logndist.mu), normdist.mu))
end
fprintf('BatchKV took %0.2fs\n', toc(startT))