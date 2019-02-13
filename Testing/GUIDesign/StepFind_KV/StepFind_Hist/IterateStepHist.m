function [outInd, outMea, outTra] = IterateStepHist(inContour, inYRes, inNoise, testP, maxIter, verbose)

if nargin < 6 || isempty(verbose)
    verbose = 1;
end
if nargin < 5 || isempty(maxIter)
    maxIter = 20;
end
if nargin < 4 || isempty(testP) %redundant, I know
    testP = [];
end
if nargin < 3 || isempty(inNoise)
    inNoise = [];
    inDec = [];
end
if nargin < 2 || isempty(inYRes)
    inYRes = .1;
end
oldP = [];

%Pass inNoise as single to instead use it as a decimation amt. for estimateNoise
if isa(inNoise, 'single')
    inDec = double(inNoise);
    inNoise = [];
end


startT = tic;
exitmsg = sprintf('max iter.s done (%d)',maxIter);
for i = 1:maxIter
            %Idea2: Smooth by lesser amounts as time goes on
        if i > 3
            fact = ceil(3*0.2/inYRes);
%         elseif i > 5
%             fact = 1;
        else
            fact = ceil(5*0.2/inYRes);
        end
    
    %Do stepfinding
    if isempty(testP) %First iter.
        fprintf('Iter%02d',i)
        [ind, mea, tra] = findStepHistV7dlomemiter(inContour, inYRes, inNoise, [], inDec);
    else %Subsequent iter.s
        %Smooth, renormalize histogram [make sum(p) = 1, not sum(p)*dx = 1] - positive y is weird
        %Aggarwal has P ~ 1e-3 for a 2,000 pt trace - probability that each pt. has a step? i.e. norm y = y/len
        x = testP(:,1);
        
        %Original: Just smooth and use
        %y = smooth(testP(:,2)); %Not sure whether to use testP(:,2) or (:,3) - don't want to prejudice for shorter steps
        
        %Idea: De-weight small jumps (want 10bp jump to be equally weighted as 4x2.5bp, so mult. by distance and renormalize)
        %weight = abs(x);
        %Cheat a bit: Over 10bp, just do 10
%         weight(weight>10) = 10;
        y = testP(:,3);% .* weight;
        %Normalize by count ? Or just to length?
       % y = y / sum(y);% / inYRes;

        y = smooth(y,fact);
        
        %Normalize to length - now it's speed-dependent (slower trace = bigger penalty - im actually ok with that)
        y = y /length(inContour);
        useP = [x(:) y(:)];
        
        fprintf('Iter%02d',i)
        [ind, mea, tra] = findStepHistV7dlomemiter(inContour, inYRes, inNoise, useP, inDec);
    end
    
    %Calculate step size histogram
    stepDist = -diff(mea);
    newP = normHist(stepDist, inYRes);
    
    if verbose
        %Keep only one figure if verbose == 2
        if verbose == 2
            clf
        else
            figure('Name',['Hist Iter. ' num2str(i)]);
        end
        %Plot fit and step size distribution
        subplot(3,1,[1 2])
        plot(inContour,'Color',[.8 .8 .8]);
        hold on;
        plot(tra);
        subplot(3,1,3), bar(newP(:,1),newP(:,2)), hold on, plot(newP(:,1),smooth(abs(newP(:,1)).*newP(:,2), fact))
        drawnow
    end
    
    %Check if we've settled on a histogram
    if isequal(newP, testP)
        exitmsg = sprintf('hist convergence on iter. %d', i);
        break;
    end
    %Sometimes hist flip-flops
    if isequal(newP, oldP)
        exitmsg = sprintf('hist flipflop on iter. %d', i);
        break;
    end
    
    %Otherwise update for next iter.
    oldP = testP;
    testP = newP;
end

fprintf('IterateStepHist ended due to: %s in %0.2fs\n', exitmsg, toc(startT))

outInd = ind;
outMea = mea;
outTra = tra;