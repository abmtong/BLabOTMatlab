function [out, inst] = plotDrugTails(inst, tmin)
%Plot the tail of the distribution of pauses of these varying conditions

%Basically, get data, AAP region only e.g. with @plotDrugTraces second output, set this as 'drA' field
%Do Viterbi fitting with procFran_pdd
%This will plot the CCDF of the tail of the dwells

roi = [0 inf]; %ROI
endcrop = 5; %Crop last few steps, to ignore pause before break
Fs = 1e3; %Fsamp
if nargin < 2
    tmin = 5; %Only take pauses over this duration
end

tfexpfit = 1; %Fit to 1exp?


figure('Name', 'PlotDrugTails')
hold on
ax=gca;
len = length(inst);
lgn = cell(1,len);
out = cell(1,len);
for i = 1:len
    %Get data
    dat = inst(i).pdd;
    
    %Remove empty
    dat = dat( ~cellfun(@isempty, dat) );
    
    %Remove bts
    dat = cellfun(@removeTrBts, dat, 'Un', 0);
    
    %Convert to in, me
    [in, me] = cellfun(@tra2ind, dat, 'Un', 0);
    
    %Calculate dwell times
    dw = cellfun(@diff, in, 'Un', 0);
    
    %Crop to roi
    dwcr = cellfun(@(x,y) x( y >= roi(1) & y <= roi(2) ), dw, me, 'Un', 0);
    
    %Crop last N dwells
    dwcr = cellfun(@(x) x(1:end-endcrop), dwcr, 'Un', 0);
    
    %Collapse
    dws = [dwcr{:}] / Fs;
    
    %Crop dwells
    dws = dws( dws > tmin );
    
    %Create CCDF
    [cx, cy] = tocdf(dws, 1);
    
    %And plot
    plot(ax, cx, cy)
    
    %Guess exp fit thru median. Tau = median / ln2
    exptau = median(dws);
    %And guess the Y-intercept of the full data. Basically, this crosses (tmin, 1), so propagate to Y-axis and scale to full data
    expa = exp(tmin/exptau) * length(dws) / length([dwcr{:}])   ;
    
    %Calculate percentage of steps
    pct = length(dws)/length([dwcr{:}])*100;
    lgn{i} = sprintf('%s', inst(i).nam);
    
    %Calculate global speed, = length(dws)/sum(dws)
    vel = length(dws)/sum(dws);
    
%     %MLE fit to 1exp
%     [m, mci] = mle(dws, 'distribution', 'exp');
%     mlefit = [m mci(2)-m];
    mm = @(x) [mean(x) std(x) length(x)];
    
    %Save
    out{i} = [pct expa exptau vel mm(dws)];
    
    
%     %PDD it
%     inst(i).dws = dws;
%     inst(i).pddp2 = pol_dwelldist_p2({dws}, struct('fitsing', 0, 'prcmax', 100, 'xrng', [2e-3 inf]));
end

%Assemble out
out = cell2mat(out(:));

axes(ax)
legend(lgn)
axis(ax, 'tight')
set(ax, 'YScale', 'log')
xlim(ax, [tmin inf])
ylim(ax, [1e-2 1])

xlabel(ax, 'Pause Duration (s)')
ylabel(ax, sprintf('CCDF of pauses over %0.0fs', tmin ))
