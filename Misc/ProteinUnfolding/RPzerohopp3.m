function out = RPzerohopp3(inst)

%Sorting options
opts.minttp = 20; %Minimum TP time; decent choice is ~Fs/Fc ?
% opts.frng = [10 12]; %Force range

%Plotting options for raw traces
opts.Fs = 25e3;
opts.crop = [6 106]; %Crop data for plotting multiple traces side-by-side, take crop(1):crop(2)
opts.lines = [0 8 17 35.6]; %Horizontal guidelines
opts.linestyle = {'--', 'Color', [.2 .2 .2]};

%Histogram options
opts.fil = 3; %Smoothing filter amount
opts.cropmeth = 1; %=1: opts.crop, =2: just TP
opts.histrng = [-10 50]; %Histogram range crop
opts.binsz = 0.5;

%Apply minttp filter
len = length(inst);
for i = 1:len
    %Apply filter to inst
    ki = inst(i).ttp >= opts.minttp;
    fns = {'ext' 'frc' 'conpro' 'frcraw' 'ttp'};
    for j = 1:length(fns)
        inst(i).(fns{j}) = inst(i).(fns{j})(ki);
    end
    %Do ttpint special since it's a mtx
    inst(i).ttpint = inst(i).ttpint(ki,:);
    inst(i).ttpintraw = inst(i).ttpintraw(ki,:);
end
out = inst;

%Plot
for i = 1:len
    tmp = inst(i);
    figure('Name', sprintf('file:%s, logtlo:%0.2f, thi:%0.2f, frc: %0.2f, minttp:%d, n:%d', tmp.name, log10(tmp.tlohi(1)), tmp.tlohi(2), median(tmp.frc), opts.minttp, length(tmp.conpro)))
    hold on
    
    %Crop data
    cp = cellfun(@(x) x(opts.crop(1):opts.crop(2)), tmp.conpro, 'Un', 0);
    cp = [cp{:}];
    Fsms = opts.Fs/1e3;
    xx = (1:length(cp))/Fsms;
    %Plot
    plot(xx,cp)
    ylim( opts.lines([1 end]) + [-10 10] )
    
    %Reconstruct 'intermediate staircase' from ttpint ... if dims match
    if size(tmp.ttpint, 2) == length(opts.lines)
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
    arrayfun(@(x) plot( x * [1 1], ylim, opts.linestyle{:}), (1/Fsms: (diff(opts.crop)+1)/Fsms:xx(end)))
    
    ylim( opts.lines([1 end]) + [-5 5] )
    
    xlabel('Time (ms)')
    ylabel('Protein Contour (nm)')
end

%Histogram
figure('Name', 'RPzerohop Histogram')
hold on
lgn = cell(1,len);
for i = 1:len
    tmp = inst(i);
    %Crop by opts.crop? or by tp?
    switch opts.cropmeth
        case 1
            %Filter and crop data
            cpf = cellfun(@(x) windowFilter(@median, x, opts.fil, 1), tmp.conpro, 'Un', 0);
            cpf = cellfun(@(x) x(opts.crop(1):opts.crop(2)), cpf, 'Un', 0);
            cpf = [cpf{:}];
            
            %Apply crop, to remove weird data
            ki = cpf >= opts.histrng(1) & cpf <=  opts.histrng(2);
            cpf = cpf(ki);
            
            %Histogram
            [hy, hx] = nhistc(cpf, opts.binsz);
            plot(hx, hy)
            
    end
    
    %Create legend entry
    lgn{i} = sprintf('log10tlo:%0.2f, frc:%0.2f', log10( tmp.tlohi(1) ), median(tmp.frc));
end
legend(lgn)

%Hmm... maybe scatter of I1/I2 duration with F duration?
figure('Name', 'RPzerohop F vs Int time')
hold on
ttps = cell(1,len);
for i = 1:len
    %Get lifetime in F vs. I's (ttpint(1) vs ttpint(2:end-1)
    tmp = inst(i);
    %Get intermediate times
    inttim = tmp.ttpint(:, 2:end-1);
    %Zero NaN/inf
    inttim(isnan(inttim))=0;
    inttim(isinf(inttim))=0;
    inttim = sum(inttim, 2);
    
    ttps{i} = [tmp.ttpint(:,1) inttim] / Fsms;
    %Scatter?
%     scatter(ttps{i}(:,1), ttps{i}(:,2))
    
    %Hm scatter probably not great, then mean/sd? 'Cross plot' ?
    mn = mean(ttps{i},1);
    sd = std(ttps{i},1);
    
    %And plot + at mean +- 1 SD. Create this from one plot?
    xx = [-1 1 0 0 0];
    yy = [0 0 0 1 -1];
    
    plot( mn(1) + xx*sd(1), mn(2) + yy*sd(2) )
    
end
legend(lgn)
xlabel('F time (ms)')
ylabel('I time (ms)')






%