function [outInd, outMea, outTra, stepDist] = BatchTT(inContour, inThr, inDec, verbose)
%inContour now a cell array of contours
if nargin < 4
    verbose = 1;
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
    [outInd, outMea, outTra] = cellfun(@(x)StepTT(x,inThr, inDec), inContour, 'Uni', 0);
else
    parfor i = 1:hei
        [outInd{i}, outMea{i}, outTra{i}] = StepTT(inContour{i},inThr, inDec);
    end
end
fprintf('\b]\n')

%Calculate step size histogram
stepDist = cellfun(@(x)-diff(x), outMea,'Uni',0);
stepDist = [stepDist{:}];
stepN = length(stepDist);
stepNp = length(stepDist(stepDist>0));
newP = normHist(stepDist, 0.2);

if verbose
    figure('Name',sprintf('%s {%s [%s]}', mfilename, inputname(1), sprintf('%0.3f ',inThr, inDec)));
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
fprintf('BatchTT took %0.2fs\n', toc(startT))