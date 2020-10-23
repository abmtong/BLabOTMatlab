function inOpts = easyAnalyze(data, inOpts)

if nargin < 2
    inOpts = easyAnalyzeOpts;
end

%Make data a cell
if ~iscell(data)
    data = {data};
end

%Filter data
dataF = cellfun(@(x) windowFilter(@mean, x, inOpts.fwid, inOpts.fdec), data, 'Un', 0);

switch inOpts.Method
    case 'Pairwise'
        fils  = [3 5 10 25];
        binsz = inOpts.binsz;
        pfils = [1 5 10] * .1/binsz;
        pfils = round(pfils);
        %Plot PWD
        sumPWDV1bmatrix(data, fils, pfils, binsz)
    case 'Stepfinding: K-V'
        BatchKV(dataF, inOpts.kvpf)
    case 'Stepfinding: KDF'
        %kdfsfind uses inputParser instead of opts, welp. Should just pick one
        kdfsfind(data, 'fpre', {inOpts.fwid, inOpts.fdec}, 'binsz', inOpts.binsz, 'kdfsd', inOpts.ksd, 'kdfmpp', inOpts.mpp);
    case 'Stepfinding: HMM'
        len = length(data);
        hmm = cell(1,len);
        %Do stepfinding: use parfor if requested
        bsz = inOpts.binsz;
        if inOpts.parpool
            parfor i = 1:len
                hmm{i} = findStepHMMv2(struct('tr', data{i}, 'binsz', bsz));
            end
        else
            hmm = cellfun(@(x)findStepHMMv2(struct('tr', x, 'binsz',inOpts.binsz)), data, 'Un', 0);
        end
        %Collect a's and plot them together
        aa = cellfun(@(x) x.a, hmm, 'Un',0);
        %Pad aa to make them equal length
        alen = cellfun(@length, aa);
        amax = max(alen);
        aa = cellfun(@(x,y) [zeros(1,(amax-y)/2)  x  zeros(1,(amax-y)/2)], aa, num2cell(alen), 'Un', 0);
        %When summing aa, weight by n pts
        tlen = cellfun(@length, data);
        %Convert a to matrix, weight with bsxfun, sum to add
        asum = sum(bsxfun(@times, reshape([aa{:}], amax, []), tlen), 2)';
        asum((amax+1)/2) = 0;
        xx = ((1:amax)-(amax-1)/2)*inOpts.binsz;
        figure, plot(xx, asum);
    case 'N-state HMM'
        hmm = cellfun(@(x)stateHMMV2(x, struct('ns',inOpts.ns)), data, 'Un', 0);
        %Collect a's and plot them together
        aa = cellfun(@(x) x.finish.a, hmm, 'Un',0);
        %Pad aa to make them equal length
        alen = cellfun(@length, aa);
        amax = max(alen);
        aa = cellfun(@(x) [zeros(1,(amax-alen)/2)  x  zeros(1,(amax-alen)/2)], 'Un', 0);
        %When summing aa, weight by n pts
        tlen = cellfun(@length, data);
        %Convert a to matrix, weight with bsxfun, sum to add
        asum = sum(bsxfun(@times, reshape([aa{:}], amax, []), tlen), 2)';
        asum((amax+1)/2) = 0;
        xx = ((1:amax)-(amax-1)/2)*inOpts.binsz;
        figure, plot(xx, asum);
    case 'Velocity distribution'
        vdist(data, inOpts);
    case 'Plot'
        plotTracesV2(inOpts);
        addbutton
    case 'Staircase'
%         dataF = splitffb(dataF, 5e3);
        vit.ssz = inOpts.ssz;
        vit.dir = inOpts.dir;
        vit.trnsprb = inOpts.trnsprb;
        vit.sig = mean(cellfun(@estimateNoise, data));
        
        if true
            len = length(dataF);
            parfor i = 1:len
                str{i} = fitVitterbiV3(dataF{i}, vit);
            end
        else
            str = cellfun(@(x) fitVitterbiV3(x, vit), dataF, 'Un', 0);
        end
        [ind, mea] = cellfun(@(x) tra2ind(x), str, 'Un', 0);
        dwells = cellfun(@diff, ind, 'Un', 0);
        steps = cellfun(@diff, mea, 'Un', 0);
        dwells = [dwells{:}];
        steps = [steps{:}];
        if vit.dir == -1
            steps = -steps;
        end
        
        
        %Plot like BatchKV. Code taken from BatchKV
        
        stepN = length(steps);
        stepNp = length(steps(steps>0));
        newP = normHist(steps, 0.25);
        
        figure('Name','EzAnalyze Staircase');
        %Plot step size distribution
        subplot2([4,1],[1 2]);
        hold on
        %make plot colors: rainbow starting at blue with period 10
        cols =    arrayfun(@(x)hsv2rgb([mod(x,1)  1 .6]), 2/3 + (1:length(dataF))/10 ,'Uni', 0);
        colsraw = arrayfun(@(x)hsv2rgb([mod(x,1) .3 .8]), 2/3 + (1:length(dataF))/10 ,'Uni', 0);
        
        cellfun(@(x,c)plot(x, 'Color', c), dataF, colsraw)
        cellfun(@(x,c)plot(x, 'Color', c), str, cols)
        
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
        try
        text(distx(maxx)*1.75, maxy*.75, sprintf('Mode: %0.3f\nN: %d, N+: %d\nMu, Sig: %0.3f, %0.3f\nMean: %0.3f\nLogMean: %0.3f\nNormMean: %0.3f', exp(logndist.mu-logndist.sigma^2), stepN, stepNp, logndist.mu,logndist.sigma, exp(logndist.mu + logndist.sigma^2/2), exp(logndist.mu), normdist.mu))
        catch
        end
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
    otherwise
        warning('Loaded inOpts method %d is invalid', src.Value)
end



