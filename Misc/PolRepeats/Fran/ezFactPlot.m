function ezFactPlot(inst, inOpts)
%Outputs of ezFactAnalyze

opts.onlycross = 0; %Only crossers?
opts.onlypick = 0; %Only picked traces? (add field of .tfpick)

opts.Fs = 1e3;
opts.binsz = 0.5;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Set opts for sumNucHist
snhop = opts;
snhop.verbose = 0;

len = length(inst);
xs = cell(1,len);
ys = cell(1,len);
es = cell(1,len);
lgn = cell(1,len);
for i = 1:len
    tmp = inst(i).drA;
    ki = true(size(tmp));
    if opts.onlycross
        ki = ki & inst(i).tfc;
    end
    if opts.onlypick
        ki = ki & inst(i).tfpick;
    end
    [ys{i}, xs{i}, yraw] = sumNucHist(tmp(ki), snhop);
    es{i} = std([yraw{:}], [], 2, 'omitnan')/opts.Fs/opts.binsz;
    lgn{i} = sprintf('%s, N=%d', inst(i).nam, sum(ki));
end

% plotNucHist_err(xs, ys, es); %Actually, errorbars are pretty small so eh. Also need to set errorbar width
plotNucHist(xs, ys, opts);
xlim([0 160])
ylim([0 4])
legend(lgn)