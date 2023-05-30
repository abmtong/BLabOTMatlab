function out = RPpass_p3(inst, inOpts)
%Plot rips from RPpassive. Similar to RPp3b

opts.fil = 20; %Filter (smooth, dont downsample)
opts.filtype = 2; %Filter type, =1 for mean, =2 for median, =3 for savitsky-golay with order 1
opts.Fs = 25e3; %Fsamp, just for calculating times (plotting). Using msec as unit.

opts.wid = [100 100]; %Pts to take on each side of the rip
opts.tpmeth = 0; %Method for cropping TPs, 0 = just window, 1 = also do Woodhouse-like TPs (cross x1 to cross x2)

%Options if tpmeth == 1
opts.tpwid = [0.1 0.9]; %Crossing lines for determining TPs
opts.tppad = 100; %Pts to pad on each side after finding the TP
opts.tppadmult = 0.5; %Pts to pad on each side, as a multiple of the tp length
opts.tpfil = 10; %Filtering for TPs for detection, different from opts.fil (filter more to get a more noise-independent TP detection

opts.tptco = [0 100]; %TP time percentiles cutoffs: only keep TPs within the two percentiles
opts.tptbinsz = 10; %Bin size for TP times (pts)

opts.splituu = 0;

opts.pwlcc = 0.35*106; %Protein size (nm)
% opts.pwlcfudge = 1; %Protein size offset, nm

%Options to KV stepfind
opts.kv = 0; %Do KV stepfinding
opts.kvmaxsteps = 5; %Maximum steps to find KV
opts.kvpen = single(5); %Penalty factor

opts.usetfpbe = [1 1]; %Uses tfpbe1 and tfpbe2, if they exist (see RPpickbyeyeGUI). Make [0 0] to disable

%Plotting options
opts.verbose = 1; %Plot
opts.conbinsz = 0.5; %Contour histogram bin size
opts.ngauss = 4; %Number of gaussians to fit contour histogram to
opts.gaussmu = [0 2 nan 11 2 nan 22 2 nan opts.pwlcc 2 nan]; %Gaussian fit guesses in form [mu sd hei]. Make sure length(gaussmu) = ngauss *3. NaN to use default guess.
opts.randkv = 0; %Chance to plot K-V fit

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(inst);
tpcrp = cell(1,len); %Transition path crop
tpcrpr = cell(1,len); %Transition path crop raw (unfiltered)
typs = cell(1,len); %Force of rip
tptimes = cell(1,len); %Transition path times, if tpmeth == 1
kvres = cell(1,len); %KV stepfinding results
for i = 1:len
    tmp = inst(i);
    hei = size(tmp.rips, 1);
    tps = cell(1,hei);
    tpsr = cell(1,hei);
    typ = zeros(1,hei);
    tpt = nan(1,hei);
    kvr = cell(1,hei);
    for j = 1:hei
        %Get protein contour
        tmp = inst(i);
        
        %Get type
        tt = tmp.rips(j,4);

        %Crop just the TP, with some padding so filtering/deconv is ok
        pad = opts.fil;
        irng = tmp.rips(j,1) - opts.wid(1) - pad : tmp.rips(j,1) + opts.wid(2) + pad;
        %If crop range is out of bounds, just skip. Shouldn't happen for 'good' files
        if irng(1) < 1 || irng(end) > length(tmp.conpro)
            %Skip this one
            tps{j} = nan;
            tpsr{j} = nan;
            continue
        end
        %And apply crop
        yy = double( tmp.conpro(irng) );
        
        %Filter
        if opts.fil > 0
            switch opts.filtype
                case 1 %Mean
                    yf = windowFilter(@mean, yy, opts.fil, 1);
                case 2 %Median
                    yf = windowFilter(@median, yy, opts.fil, 1);
                case 3 %Sgolay, rank 1
                    yf = sgolayfilt(yy, 0, 1+2*opts.fil);
                otherwise %Undefined, fallback to mean
                    warning('Filter type %d not defined, using mean', opts.filtype)
                    yf = windowFilter(@mean, yy, opts.fil, 1);
            end
        else
            yf = yy;
        end
        
        %Un-pad
        yy = yy(pad+1:end-pad);
        yf = yf(pad+1:end-pad);
        
        %Crop to just the transition path, if asked
        if opts.tpmeth == 1
            %Only do so if this is a crossing excursion
            if tt == 1 || tt == 2
                %Bounds are 0 and opts.pwlcc, two lines x1 and x2 are at tpwid(1) and tpwid(2) times that distance (e.g. 0.2, 0.8 = at 20% and 80% the way there)
                %Find the last time the trace crosses x1 to the first time it crosses x2
                % Lets assume the crossing is one-way, so we don't have to check for going backwards
                %Filter specially for this method
                yftp = windowFilter(@mean, yy, opts.tpfil, 1);
                %If it's a U>F rip, invert yf
                if tt == 1
                    yftp = opts.pwlcc - yftp;
                end
                ind1 = find( yftp < opts.tpwid(1) * opts.pwlcc, 1, 'last');
                ind2 = find( yftp > opts.tpwid(2) * opts.pwlcc, 1, 'first');
                tmptptime = ind2-ind1+1;
                %Only save if ind1 and ind2 were found (not empty time)
                if ~isempty(tmptptime)
                    %Save tp time
                    tpt(j) = tmptptime;
                    %And NaN out things outside of ind1:ind2, with some padding
                    pad2 = round( (ind2 - ind1) * opts.tppadmult );
                    ind1 = max( 1, ind1 - opts.tppad - pad2 );
                    ind2 = min( length(yy), ind2 + opts.tppad + pad2);
                    ki = false(1,length(yy));
                    ki(ind1:ind2) = true;
                    yy(~ki) = nan;
                    yf(~ki) = nan;
                else
                    %TP wasnt found, so NaN the entire trace to reject it
                    yy = nan(size(yy));
                    yf = nan(size(yy));
                end
            end
        end
        
        if opts.splituu == 1
            if tt == 0 %Split U>Us to first half
                [~, ind1] = min(yf);
                yf(1:ind1) = nan;
            elseif tt == 3 %Split FFs to first half
                [~, ind1] = max(yf);
                yf(1:ind1) = nan;
            end
        elseif opts.splituu == 2
            if tt == 0 %Split U>Us to second half
                [~, ind1] = min(yf);
                yf(ind1:end) = nan;
            elseif tt == 3 %Split FFs to second half
                [~, ind1] = max(yf);
                yf(ind1:end) = nan;
            end
        end
        
        %do KV if asked for
        if opts.kv
            %Stepfind with KV. Do on raw data, since its better that way for accurate QE calculation
            [in, me] = AFindStepsV5(yy, opts.kvpen, opts.kvmaxsteps, 0);
            %Switch from mean to median
            for k = 1:length(me)
                me(k) = median(yy(in(k):in(k+1)-1));
            end
            kvr{j} = me;
            
            %Chance to plot
            if opts.verbose && (rand < opts.randkv)
                figure
                hold on
                xx = ( -opts.wid(1):opts.wid(2) ) / opts.Fs * 1e3;
                plot(xx,yy, 'Color', [.7 .7 .7])
                plot(xx,yf, 'b')
                plot(xx,ind2tra(in,me))
                drawnow
            end
        end
        
        %Save
        tps{j} = yf;
        tpsr{j} = yy;
        typ(j) = tt;
    end
    
    %Save
    tpcrp{i} = tps;
    tpcrpr{i} = tpsr;
    typs{i} = typ;
    tptimes{i} = tpt;
    kvres{i} = kvr;
end
%Concatenate cell-of-cells
tpcrp = [tpcrp{:}];
tpcrpr = [tpcrpr{:}];
typs = [typs{:}];
tptimes = [tptimes{:}];
kvres = [kvres{:}];

%Remove empty entries if they were skipped, or wild outliers or NaN
ki1 = ~cellfun(@(x)isempty(x) || max(abs(x))>opts.pwlcc*100 || all(isnan(x)), tpcrp);

% %Remove entries manually picked with RPpickbyeyeGUI //doesnt work in this guy
% ki3 = true(size(tpcrp));
% if isfield(inst, 'tfpbe1') && opts.usetfpbe(1)
%     ki3 = ki3 & [inst.tfpbe1];
% end
% if isfield(inst, 'tfpbe2') && opts.usetfpbe(2)
%     ki3 = ki3 & [inst.tfpbe2];
% end
% if ~all(ki3)
%     fprintf('Rejected %d/%d traces by picking\n', sum(~ki3), length(ki3))
% end

%Apply TP time cutoff if TPtimes are calculated
if opts.tpmeth
    %TP time cutoff
    ki2 = tptimes >= prctile(tptimes, opts.tptco(1)) & tptimes <= prctile(tptimes, opts.tptco(2));
    %But only for the UF or FU traces
    ki2 = ki2 | typs == 0 | typs == 3;
else
    ki2 = true(size(tpcrp));
end


%Join and apply data removal
% ki = ki1 & ki2 & ki3 & ki4 & ki5;
ki = ki1 & ki2;
tpcrp = tpcrp(ki);
tpcrpr = tpcrpr(ki);
typs = typs(ki);
% inst = inst(ki);
tptimes = tptimes(ki);
kvres = kvres(ki);

out.tps = tpcrp;
out.tpsr = tpcrpr;
out.typs = typs;
out.tptimes = tptimes;
out.kvres = kvres;

if opts.verbose
    %Plot TPs, 3x2 matrix of U>F, F>U, and excursions
    figure('Name', sprintf('RossPull passive p3. Name: %s, fil: %d, filtype, %d, wid: [%d %d], tpmeth: %d, usetfpbe:[%d %d]', inputname(1), opts.fil, opts.filtype, opts.wid(1), opts.wid(2), opts.tpmeth, opts.usetfpbe(1), opts.usetfpbe(2) ), 'Color', [1 1 1])
    
    %Plot typs == 1: U>F
    ax = subplot(2,4,1); hold on
    plotTPs(ax, tpcrp( typs == 1) );
    title(sprintf('U>F, N=%d', sum(typs==1)))
    ax = subplot(2,4,5); hold on
    if opts.kv
        plotHis(ax, kvres( typs == 1) );
    else
        plotHis(ax, tpcrp( typs == 1) );
    end
    
    %Plot typs == 2: F>U
    ax = subplot(2,4,2); hold on
    plotTPs(ax, tpcrp( typs == 2) );
    title(sprintf('F>U, N=%d', sum(typs==2)))
    ax = subplot(2,4,6); hold on
    if opts.kv
        plotHis(ax, kvres( typs == 2) );
    else
        plotHis(ax, tpcrp( typs == 2) );
    end
    
    %Plot UU/FF traces or TP time distribution, depending on tpmeth
    if opts.tpmeth ~= 1
        %Plot typs == 0: U>U
        ax = subplot(2,4,3); hold on
        plotTPs(ax, tpcrp( typs == 0) );
        title(sprintf('U>U, N=%d', sum(typs==0)))
        ax = subplot(2,4,7); hold on
        if opts.kv
            plotHis(ax, kvres( typs == 0) );
        else
            plotHis(ax, tpcrp( typs == 0) );
        end
        
        %Plot typs == 3: F>F
        ax = subplot(2,4,4); hold on
        plotTPs(ax, tpcrp( typs == 3) );
        title(sprintf('F>F, N=%d', sum(typs==3)))
        ax = subplot(2,4,8); hold on
        if opts.kv
            plotHis(ax, kvres( typs == 3) );
        else
            plotHis(ax, tpcrp( typs == 3) );
        end
    elseif opts.tpmeth == 1 %Plot TP time distribution
        subplot(2,4, [3 4 7 8]);
        hold on
        
        leg = cell(1,2);
        for i = 1:2
            %Create and plot CCDF
            xx = sort( tptimes( typs == i ) );
            yy = (length(xx):-1:1)/ length(xx);
            colind = get(gca, 'ColorOrderIndex');
            plot(xx,yy, 'o')
            set(gca, 'ColorOrderIndex', colind)
            %Fit first 80% of data to 1exp
            ki = yy > 0.2;
            fitfcn = @(x0,x) exp(-x/x0(1))*x0(2);
            ft = lsqcurvefit(fitfcn, [median(xx)*log(2) 1], xx(ki), yy(ki) );
            plot(xx, fitfcn(ft, xx));
            leg{i} = sprintf('1exp, \\tau = %0.2fpts', ft(1));
        end
        legend({'U>F' leg{1} 'F>U' leg{2}})
        set(gca, 'YScale', 'log')
        %Fit these to 1exp?
        axis tight
        %Ylim to see 90% of the data
        ylim([0.1 1])
        xl = xlim;
        xlim([0 xl(2)]);
        ylabel('CCDF')
        xlabel('Time (pts)')
        title('TP Time Distribution')
    end
end

    function plotTPs(ax, tps)
        if isempty(tps)
            return
        end
        %First, make all the tps the same length
        maxlen = max(cellfun(@length, tps));
        tps = cellfun(@(x) [x nan( 1, maxlen-length(x))], tps, 'Un', 0);
        
        xx = ((1:maxlen) - opts.wid(1) -1) /opts.Fs*1e3;
        %Plot trace snippets
        cellfun(@(x)plot(ax, xx ,x), tps)
        %Plot line at bottom and top
        plot(ax, [xx(1) xx(end)] , [0 0], 'r', 'LineWidth', 1)
        plot(ax, [xx(1) xx(end)] , opts.pwlcc * [1 1], 'g', 'LineWidth', 1)
        %plot 'median' one
        medtr = median( reshape( [tps{:}], length(tps{1}), [] ), 2, 'omitnan');
        plot(ax, xx, medtr, 'k', 'LineWidth', 2)
        axis tight
        yl = [0 opts.pwlcc] + opts.pwlcc * 0.2 * [-1 1];
%         yl = [ min(medtr, [], 'omitnan') max(medtr, [], 'omitnan') ] + range(medtr) * 0.5 .* [-1 1];
        ylim(ax, yl)
        title('Transition Paths')
        xlabel('Time (ms)')
        ylabel('Protein Contour (nm)')
        
    end

    function plotHis(ax, tps)
        if isempty(tps)
            return
        end
        
        %Plot contour histogram
        [~, xx, ~, y] = nhistc( [tps{:}], opts.conbinsz );
        %Normalize: total N per bin -> N per molecule per nm
        y = y / opts.conbinsz / length(tps) / opts.Fs * 1e3;
        %Plot and fit to N gaussians
        ngaufit_cf(xx,y, opts.ngauss, ax, opts.gaussmu);
        yl = [0 opts.pwlcc] + opts.pwlcc * 0.2 * [-1 1];
        xlim(yl)
        title('Residence Time Histogram')
        xlabel('Protein Contour (nm)')
        ylabel('Time (ms/nm)')
        axis tight
        
    end

end
