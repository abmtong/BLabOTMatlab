function [out, outraw] = RPzerohopp3(inst, varargin)

%Sorting options
opts.minttp = 20; %Minimum TP time; decent choice is ~Fs/Fc*N ?

opts.maxfttp = inf; %Max F TP time; to try to filter really long F's
% opts.frng = [10 12]; %Force range

%Plotting options for raw traces
opts.Fs = 25e3;
opts.crop = [6 106]; %Crop data for plotting multiple traces side-by-side, take crop(1):crop(2)
% opts.crop = [6 1006]; %1006 for all data (for histogram)
% opts.crop = [6 256]; %100pts for small snip

opts.tpcrop = 0; %Crop 'tp style' : take ttpraw to find first state after F
opts.tpcropwid = [-100 100]; %Window around rip

opts.plottra = 0; %Plot intermediate traces (or just guidelines)
opts.lines = [0 8 17 35.6]; %Horizontal guidelines
opts.linestyle = {'--', 'Color', [.2 .2 .2]};

%Histogram options
opts.fil = 3; %Smoothing filter amount
% opts.cropmeth = 1; %=1: opts.crop, =2: just TP
opts.histrng = [-30 50]; %Histogram range crop. Also works as min x for plotting raw traces
opts.binsz = 0.5;

opts.fitgauss = 0; %Plot fit gaussians or not

%Starting point options
opts.spttpmin = 5; %Start Point TP time minimum, i.e. first state longer than this = starting state
opts.spverbose = 1; %Plot histograms grouped by starting point

%HandleOpts
opts = handleOpts(opts, varargin);

%Apply minttp filter
len = length(inst);
for i = 1:len
    %Apply filters to inst
    ki = inst(i).ttp >= opts.minttp;
    ki2 = inst(i).ttpint(:,1)' < opts.maxfttp;
    ki = ki & ki2;
    
    fns = {'ext' 'frc' 'conpro' 'frcraw' 'ttp'};
    for j = 1:length(fns)
        inst(i).(fns{j}) = inst(i).(fns{j})(ki);
    end
    %Do ttpint special since it's a mtx
    fnsmtx = {'ttpint' 'ttpintraw'};
    for j = 1:length(fnsmtx)
        inst(i).(fnsmtx{j}) = inst(i).(fnsmtx{j})(ki,:);
    end
end
outraw = inst;

%Plot
for i = 1:len
    tmp = inst(i);
    figure('Name', sprintf('file:%s, logtlo:%0.2f, thi:%0.2f, frc: %0.2f, minttp:%d, n:%d', tmp.name, log10(tmp.tlohi(1)), tmp.tlohi(2), median(tmp.frc), opts.minttp, length(tmp.conpro)))
    hold on
    
    if opts.tpcrop
        %Crop data by 'tp-like' method (window around ttpintraw(i,2) )
        hei = length(tmp.conpro);
        cpraw = cell(1,hei);
        for j = 1:hei
            tpind = tmp.ttpintraw(j,2) + opts.tpcropwid;
            %Might be nan (if it never reaches)
            if any(isnan(tpind))
                continue
            end
            %Window might throw it out of the data range
            tpind = min( max(tpind, 1) , length( tmp.conpro{j} ) );
            cpraw{j} = [tmp.conpro{j}( tpind(1):tpind(2) ) nan(1, diff(opts.tpcropwid) - diff(tpind) ) ]; %Extract, pad nan to tpcrop length
            
            %Alternately, reject over some threshold since it's probably fully folded?
        end
        cp = [cpraw{:}];
        trlen = diff(opts.tpcropwid) + 1;
    else
        %Crop data by opts.crop
        cp = cellfun(@(x) x(opts.crop(1):opts.crop(2)), tmp.conpro, 'Un', 0);
        cp = [cp{:}];
        trlen = diff(opts.crop) + 1;
    end
    %If no pass, skip
    if isempty(cp)
        continue
    end
    
    Fsms = opts.Fs/1e3;
    xx = (1:length(cp))/Fsms;
    %Plot
    plot(xx, max( opts.histrng(1), cp ) ); %Plot with minimums
    ylim( opts.lines([1 end]) + [-10 10] )
    
    %Reconstruct 'intermediate staircase' from ttpint ... if dims match
    if opts.plottra && size(tmp.ttpint, 2) == length(opts.lines)
        %This is a [in, me] staircase 
        hei = length(tmp.conpro);
        tmptra = cell(1,hei);
        for j = 1:hei
            %Get 'dwells' for intermediates
            dw = [1 tmp.ttpint(j,:)];
            %Handle NaN/Inf... just zero
            dw(isnan(dw)) = 0;
            dw(isinf(dw)) = 0;
            
            in = cumsum(dw) + tmp.ttpintraw(j,1) -1;
            me = opts.lines;
            
            %Pad to full length
            in(end) = length(tmp.conpro{1});
            %Turn to staircase
            tmptra{j} = ind2tra(in,me);
            %Crop the same way
            tmptra{j} = tmptra{j}(opts.crop(1):opts.crop(2));
            
        end
        tmptra = [tmptra{:}];
        plot(xx, tmptra, opts.linestyle{:})
    else
        %Fallback: Horizontal guidelines
        arrayfun(@(x) plot(xlim, x * [1 1], opts.linestyle{:}), opts.lines);
    end
    
    %Add vertical guidelines
    arrayfun(@(x) plot( x * [1 1], ylim, opts.linestyle{:}), (1/Fsms: (trlen)/Fsms:xx(end)))
    
    ylim( opts.lines([1 end]) + [-5 5] )
    
    xlabel('Time (ms)')
    ylabel('Protein Contour (nm)')
end

%Histogram
figure('Name', 'RPzerohop Histogram')
hold on
ax = gca;
lgn = cell(1,len);
for i = 1:len
    tmp = inst(i);
    %Crop like for plotting but with filtering now. Maybe combine? eh copy code
    cpf = cellfun(@(x) windowFilter(@median, x, opts.fil, 1), tmp.conpro, 'Un', 0);
    
    if opts.tpcrop
        %Crop data by 'tp-like' method (window around ttpintraw(i,2) )
        hei = length(tmp.conpro);
        cpraw = cell(1,hei);
        for j = 1:hei
            tpind = tmp.ttpintraw(j,2) + opts.tpcropwid;
            %Might be nan (if it never reaches)
            if any(isnan(tpind))
                continue
            end
            %Window might throw it out of the data range
            tpind = min( max(tpind, 1) , length( tmp.conpro{j} ) );
            cpraw{j} = [cpf{j}( tpind(1):tpind(2) ) nan(1, diff(opts.tpcropwid) - diff(tpind) ) ]; %Extract, pad nan to tpcrop length
            
            %Alternately, reject over some threshold since it's probably fully folded?
        end
        cp = [cpraw{:}];
        trlen = diff(opts.tpcropwid) + 1;
    else
        %Crop data by opts.crop
        cp = cellfun(@(x) x(opts.crop(1):opts.crop(2)), cpf, 'Un', 0);
        cp = [cp{:}];
        trlen = diff(opts.crop) + 1;
    end
    cpf = cp;
    
    %Apply ycrop, to remove weird data
    ki = cpf >= opts.histrng(1) & cpf <=  opts.histrng(2);
    cpf = cpf(ki);
    
    %Histogram
    [~, hx, ~, hn] = nhistc(cpf, opts.binsz);
    ht = hn/opts.Fs*1e3 / opts.binsz / length(tmp.conpro);
    %Time = points_in_bin/n_traces {points per bin per trace} / Fs / binsz =units= pts/bin/trace * s/hz * bin/nm = s/nm yes
    plot(ax, hx, ht)
    
    %Add gaussians
    if opts.fitgauss
        %Make special graph just so fitNGaussiansGraph calls the right gca... should just make passable but EH
        fg = figure;
        plot(hx, ht)
        fngg = fitNGaussiansGraph( opts.lines );
        ylabel('Residence Time (ms/nm)')
        xlabel('Protein Contour (nm)')
        out.gauss{i} = fngg;
        title(sprintf('log10tlo:%0.2f, frc:%0.2f', log10( tmp.tlohi(1) ), median(tmp.frc)))
        delete(fg);
    else
        
    end
    
    %Create legend entry
    lgn{i} = sprintf('log10tlo:%0.2f, frc:%0.2f', log10( tmp.tlohi(1) ), median(tmp.frc));
end
legend(ax, lgn)
ylabel(ax, 'Residence Time (ms/nm)')
xlabel(ax, 'Protein Contour (nm)')

%Hmm... maybe scatter of I1/I2 duration with F duration?

if false
    figure('Name', 'RPzerohop F vs Int time')
    hold on
    ttps = cell(1,len);
    for i = 1:len
        %Get lifetime in F vs. I's (ttpint(1) vs ttpint(2:end-1)
        tmp = inst(i);
        %Get intermediate times
        inttim = tmp.ttpint(:, 2:end-1);
        %     inttim = tmp.ttpint(:, 3); %Just I2
        %Zero NaN/inf
        inttim(isnan(inttim))=0;
        inttim(isinf(inttim))=0;
        inttim = sum(inttim, 2);
        %Get F times
        ftim = tmp.ttpint(:,1);
        %Zero NaN/inf
        ftim(isnan(ftim))=0;
        ftim(isinf(ftim))=0;
        
        
        ttps{i} = [ftim inttim] / Fsms;
        %Scatter?
        %     scatter(ttps{i}(:,1), ttps{i}(:,2))
        
        %Hm scatter probably not great, then mean/sd? 'Cross plot' ?
        mn = mean(ttps{i},1);
        sd = std(ttps{i},1);
        sem = sd / sqrt( length(ttps{i}) );
        
        %And plot + at mean +- 1 SD. Create this from one plot
        xx = [-1 1 0 0 0];
        yy = [0 0 0 1 -1];
        
        %     plot( mn(1) + xx*sd(1), mn(2) + yy*sd(2) )
        plot( mn(1) + xx*sem(1), mn(2) + yy*sem(2) )
        
    end
    legend(lgn)
    xlabel('F time (ms)')
    ylabel('I time (ms)')
end


% %F/I Lifetime CCDF
% ccdf = @(x) plot(sort(x, 'descend'), (1:length(x))/length(x) );
% nint = size( inst(1).ttpint, 2) -1;
% for i = 1:nint
%     figure('Name', sprintf('I%d', i-1))
%     hold on
%     for j = 1:len
%         ccdf( inst(j).ttpint(:,i) )
%     end
%     legend(lgn);
%     set(gca, 'YScale', 'log')
%     axis tight
% end

%F/I/U starting point
nst = size( inst(1).ttpint, 2);
rawn = zeros(len, nst);
figure('Name', 'Initial State')
for i = 1:len
    %Find first crossing of ttpmin of ttpint
    tmp = cumsum( inst(i).ttpint, 2 ) > opts.spttpmin;
    tmp(:,end) = true;
    nn = size(tmp,1);
    
    firsttp = arrayfun(@(x) find( tmp(x,:), 1, 'first'), 1:nn);
    rawn(i,:) = histcounts(firsttp, (0:nst) + 0.5 );
    %Below is same code as above two lines but in for loop , not terrible arrayfun
%     for j = 1:nn
%         ind = find( tmp(j,:), 1, 'first');
%         rawn(i, ind) = rawn(i, ind) + 1;
%     end

    if opts.spverbose
        %Plot per-starting TP
        %Copy histogram code from above
        
        %Generate state name (F/I1/I2/.../U)
        stnam = arrayfun(@(x) sprintf('I%d', x), 0:nst-1, 'Un', 0);
        stnam{1} = 'F';
        stnam{end}='U';
        
        %Filter and crop data
        cpf = cellfun(@(x) windowFilter(@median, x, opts.fil, 1), inst(i).conpro, 'Un', 0);
        cpf = cellfun(@(x) x(opts.crop(1):opts.crop(2)), cpf, 'Un', 0);
        %Apply crop, to remove weird data
        cpf = cellfun(@(x) x(x >= opts.histrng(1) & x <=  opts.histrng(2)),cpf, 'Un', 0);
        
        for j = 1:nst
            %Histogram
            [~, hx, ~, hn] = nhistc([cpf{ firsttp == j }], opts.binsz);
            ht = hn/opts.Fs*1e3 / opts.binsz / sum(firsttp == j);
            %Time = points_in_bin/n_traces {points per bin per trace} / Fs / binsz =units= pts/bin/trace * s/hz * bin/nm = s/nm yes
            ttl = sprintf('%s starting at %s, log10tlo:%0.2f, frc:%0.2f', inst(i).name, stnam{j}, log10( inst(i).tlohi(1) ), median(inst(i).frc));
            figure('Name', ttl )
            ax=gca;
            plot(ax, hx, ht)
            
            if isempty(hx)
                continue
            end
            
            %Add gaussians
            if opts.fitgauss
                %Make special graph just so fitNGaussiansGraph calls the right gca... should just make passable but EH
                fg = figure;
                plot(hx, ht)
                fngg = fitNGaussiansGraph( opts.lines );
                ylabel('Residence Time (ms/nm)')
                xlabel('Protein Contour (nm)')
                out.intgauss{i,j} = fngg;
                title( ttl )
                delete(fg);
            end
        end
    end
    
end



barlgn = arrayfun(@(x) sprintf('I%d', x), 0:nst-1, 'Un', 0);
barlgn{1} = 'F';
barlgn{end}='U';

%Normalize
nper = sum(rawn, 2);
barth = bsxfun(@rdivide, rawn, nper );

bar(barth, 'stacked')
legend(barlgn)
ylim([0 1])
ax = gca;
ax.XTickLabel = lgn;

out.statestats =[barth rawn nper];




