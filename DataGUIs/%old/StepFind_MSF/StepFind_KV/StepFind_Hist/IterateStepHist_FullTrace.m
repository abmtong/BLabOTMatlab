function [outInd, outMea, outTra, stepDist, firstP] = IterateStepHist_FullTrace(inContour, inYRes, inNoise, useP, maxIter, verbose)
%inContour now a cell array of contours

if nargin < 6 || isempty(verbose)
    verbose = 1;
end
if nargin < 5 || isempty(maxIter)
    maxIter = 20;
end
if nargin < 4 || isempty(useP)
    useP = [];
end
if nargin < 3 || isempty(inNoise)
    inNoise = [];
    inDec = [];
end
if nargin < 2 || isempty(inYRes)
    inYRes = .1;
end
oldP = [];
testP = [];
%Pass inNoise as single to instead use it as a decimation amt. for estimateNoise
if isa(inNoise, 'single')
    inDec = double(inNoise);
    inNoise = [];
end

startT = tic;
exitmsg = sprintf('max iter.s done (%d)',maxIter);
hei = length(inContour);
Npts = sum(cellfun(@length, inContour));
%Shift inContour so plot is nice (magnitude of inContour is irrelevant)
for i = 1:hei
    inContour{i} = 9e3+ inContour{i} - inContour{i}(1) - i*20;
end

for i = 1:maxIter
    loopT = tic;
    %Progress Meter, if i==1 (to get a feel for iter. speed)
    dash = '-';
    if i == 1 %Full bar, to "measure" from 
        fprintf('[%s]\n',dash(ones(1,length(inContour))))
    end
    %Fill bar on 1o or 2o iter.s, next iterations will be similar to 2o
    if i == 1 || i == 2
        fprintf('[\n')
        %Do stepfinding
%         [ind, mea, tra] = cellfun(@(x)findStepHistV7e(x, inYRes, inNoise, useP, inDec, 2), inContour, 'Uni',0);
        parfor j = 1:hei
            [ind{j}, mea{j}, tra{j}] = findStepHistV7e(inContour{j}, inYRes, inNoise, useP, inDec, 3);
        end
        fprintf('\b]\n')
    else
        parfor j = 1:hei
            [ind{j}, mea{j}, tra{j}] = findStepHistV7e(inContour{j}, inYRes, inNoise, useP, inDec, 0);
        end
    end
    %Calculate step size histogram
    stepDist = cellfun(@(x)-diff(x), mea, 'Uni', 0);
    stepDist = [stepDist{:}];
    newP = normHist(stepDist, inYRes);
    if i == 1 %save firstP for 
        assignin('base', sprintf('Iter_FirstP_%s', datestr(now, 'HHMMSS')), newP);
        firstP = newP;
    end
    %Smooth, renormalize histogram [make sum(p) = 1, not sum(p)*dx = 1] - positive y is weird
    x = newP(:,1);
    n = newP(:,3);
    
    if i == 1 %Choose smoothing factor for histogram
        fg = figure('Position',[0 0 1920 1080]);
        sz = {4 5};
        mult = 2;
        for j = 1:prod([sz{:}])
            subplot(sz{:},j)
            bar(x,n)
            hold on
            fact = j*mult;
            plot(x, windowFilter(@gaussMean, n, fact,1), 'LineWidth', 1.5);
            title(num2str(fact))
            xlim([0 10])
            ylim([0 max(n)])
        end
        resp = inputdlg('Smoothing Factor');
        smoothfact = str2double(resp);
        close(fg)
    end
    y = windowFilter(@gaussMean, n, smoothfact,1);
    
    %Normalize to length (P = probabilty that, at a given point, there will be a step of that size)
    y = y /Npts;
    useP = [x(:) y(:)];
    
    if verbose
        %Keep only one figure if verbose == 2
        if verbose == 2
            clf
        else
            figure('Name',['Hist Iter. ' num2str(i)]);
        end
        %Plot step size distribution
        ax1 = subplot(3,1,[1 2]);
        hold on
        cellfun(@(x)plot(x,'Color',[.7 .7 .7]), inContour)
        cellfun(@plot, tra)
        
        ax2 = subplot(3,1,3);
        
        
        bary = newP(:,2);
        bary = bary /max(bary)*2; %Bar, plot norm'd to have max=2
        ploty =y/max(y) * max(bary);
        plotpen = -log(y)/4.5; %pen. norm'd to be a multiple of the regular penalty
        
        bar(x,bary)
        hold on
        plot(x,ploty)
        plot(x,plotpen)
        line([x(1) x(end)], [1 1])
        ylim(ax2, [0 2])
        
        [pks, pkind] = findpeaks(double(ploty),'MinPeakHeight',max(ploty)/20);
        pkloc= double(x(pkind));
        for j = 1:length(pks)
            text(pkloc(j), pks(j), num2str(pkloc(j)))
        end
        starty = randi(length(inContour),1);
        ylim(ax1, [-100 0] - 20*starty +9000)
        xlim(ax1, [1 500])
        drawnow
    end
    
    %Check if we've settled on a histogram
    if isequal(newP, testP)
        exitmsg = sprintf('hist convergence on iter. %d', i);
        break;
    end
    %Sometimes hist flip-flops, esp. if @smooth is used (instead of e.g. gaussian)
    if isequal(newP, oldP)
        exitmsg = sprintf('hist flipflop on iter. %d', i);
        break;
    end
    
    %Otherwise update for next iter.
    oldP = testP;
    testP = newP;
    
    fprintf('Iter %02d took %0.2fm\n', i, toc(loopT)/60)
end

fprintf('IterateStepHist ended due to: %s in %0.2fs\n', exitmsg, toc(startT))

outInd = ind;
outMea = mea;
outTra = tra;