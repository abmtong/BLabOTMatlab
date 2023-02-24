function out = anConTime(inst, fns, inOpts)
%Not a great name
%Analyzes compaction time vs. expansion time

opts.extco = 6000; %bp, Extended = cross this number
opts.Fs = 1e3;
opts.fitmeth = 3; %Fit method, see code
opts.tmaxfit = 60; %Max compaction time for linear fitting (ignore others), fitmeth 1
opts.sdmult = 2; %SD mult for outlier detection, fitmeth 2/4
if nargin > 2
    opts = handleOpts(opts, inOpts);
end

if nargin < 2 || isempty(fns)
    fns = fieldnames(inst);
end

len = length(fns);
for i = 1:len
    tmpst = inst.(fns{i});
    
    %Find unraveling time (first pt. over a threshold. Found in AnUnravel, but just do it again here...)
    thi = cellfun(@(x) find(x > opts.extco, 1, 'first'), tmpst.hi, 'Un', 0);
    %Deal with emptys [these never crossed opts.extco: set to full time? remove?]
    ki = cellfun(@isempty, thi);
    thi(ki) = cellfun(@length, thi(ki), 'Un', 0);
    
    
    %Find compaction time (just length of traces)
    tlo = cellfun(@length, tmpst.lo);
    
%     %Actually NaN out the ones that never crossed?
%     thi(ki) = {nan};
    
    
    %Match up pairs of unraveling traces and compaction traces
    %For each unraveling trace segment...
    hei = length(tmpst.hiN);
    tmpout = nan(hei,2);
    lofs = '%06dN%02d_L%02d.mat';
    hifs = '%06dN%02d_H%02d.mat';
    for j = 1:hei
        %The _L## file is followed by the _H##+1 file, so find these pairs
        %Scan this name for MMDDYYN##_L##.mat
        hiss = sscanf(tmpst.hiN{j}, hifs)';
        tmpind = find(strcmp(tmpst.loN, sprintf(lofs, hiss + [0 0 -1]) ),1);
        if tmpind
            %Add this pair to the list
            tmpout(j,:) = [ tlo(tmpind) thi{j} ] / opts.Fs;
        end
    end
    %Remove NaNs
    ki = ~isnan(tmpout(:,1)) & ~isnan(tmpout(:,2));
    out.(fns{i}) = tmpout(ki,:);
end

figure('Color', [1 1 1]), hold on
fitstr = cell(1,len);
for i = 1:len
    %Sort
    xx = out.(fns{i})(:,1);
    yy = out.(fns{i})(:,2);
    [xx, si] = sort(xx);
    yy = yy(si);
    %Plot
    coi = get(gca, 'ColorOrderIndex');
    plot(xx, yy, 'o')
    %Linear fit
    switch opts.fitmeth
        case 1 %Max time cutoff
            ki = xx < opts.tmaxfit;
            pf = polyfit(xx(ki),yy(ki),1);
            yf = polyval(pf, xx);
            set(gca, 'ColorOrderIndex', coi);
            plot(xx,yf);
            %Calculate R-squared
            rsq = 1 - sum((yf - yy).^2)/sum( (yy-mean(yy)).^2 );
            
            fitstr{i} = sprintf('Linear (cutoff %ds), R^2 = %0.3f', opts.tmaxfit, rsq);
        case 2 %Re-fit with cutoffs
            while true
                %Fit all data...
                pf = polyfit(xx,yy,1);
                yf = polyval(pf,xx);
                %Remove outliers...
                rsd = yf - yy;
                ki = abs(rsd) < opts.sdmult * std(rsd);
                %Repeat until no more outliers
                if all(ki)
                    break
                end
                fprintf('Removed %d outliers from %s\n', sum(~ki), fns{i})
                xx = xx(ki);
                yy = yy(ki);
            end
            set(gca, 'ColorOrderIndex', coi);
            plot(xx,yf)
            %Calculate R-squared
            rsq = 1 - sum((yf - yy).^2)/sum( (yy-mean(yy)).^2 );
            
            fitstr{i} = sprintf('Linear (outliers removed), R^2=%0.3f', rsq);
        case 3 %LAD fit
            xg = polyfit(xx,yy,1); %Use least-squares result as a starting guess
            pf = fminsearch( @(x) sum(abs( xx * x(1) + x(2) - yy )) , xg);
            yf = xx * pf(1) + pf(2);
            %Calculate R-squared
            rsq = 1 - sum(abs(yf - yy).^2)/sum( abs(yy-mean(yy)).^2 );
            pearr = cov(xx,yy); %output of cov is [sig_xx sig_xy; sig_yx sig_yy];
            pearr = pearr(1,2)/sqrt(pearr(1,1)*pearr(2,2));
            set(gca, 'ColorOrderIndex', coi);
            plot(xx,yf)
            fitstr{i} = sprintf('Linear (LAD), R = %0.3f, R^2=%0.3f', pearr, rsq);
        case 4 %LAD with outlier removal
            while true
                %Fit
                xg = polyfit(xx,yy,1); %Use least-squares result as a starting guess
                pf = fminsearch( @(x) sum(abs( xx * x(1) + x(2) - yy )) , xg);
                yf = xx * pf(1) + pf(2);
                
                %Remove outliers...
                rsd = yf - yy;
                ki = abs(rsd) < opts.sdmult * std(rsd);
                %Repeat until no more outliers
                if all(ki)
                    break
                end
                fprintf('Removed %d outliers from %s\n', sum(~ki), fns{i})
                xx = xx(ki);
                yy = yy(ki);
            end
            %Calculate R-squared
            rsq = 1 - sum(abs(yf - yy).^2)/sum( abs(yy-mean(yy)).^2 );
            pearr = cov(xx,yy); %output of cov is [cov_xx cov_xy; cov_yx cov_yy], i.e. [varx cov; cov vary];
            pearr = pearr(1,2)/sqrt(pearr(1,1)*pearr(2,2));
            
            set(gca, 'ColorOrderIndex', coi);
            plot(xx,yf)
            fitstr{i} = sprintf('Linear (LAD, outliers removed), R = %0.3f, R^2=%0.3f', pearr, rsq);
            
    end
    %Actually, for those that trim, store the trimmed ones
    out.(fns{i}) = [xx(:) yy(:)];
end



xlabel('Compaction time (s)')
ylabel('Decompaction time (s)')

lgn = [fns(:)'; fitstr];
legend(lgn(:)')

