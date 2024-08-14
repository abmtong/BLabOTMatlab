function ezFactPlot(inst, varargin)
%Outputs of ezFactAnalyze

opts.onlycross = 1; %Only crossers?
opts.onlypick = 1; %Only picked traces? (add field of .tfpick)
opts.pdd = 0; %Use PDD for RTH?

opts.Fs = 1e3;
opts.binsz = 0.5;

if nargin > 1
    %Handle inputting opts as NVPs
    if length(varargin) > 1
        inOpts = struct(varargin{:});
    else
        inOpts = varargin{1};
    end
    opts = handleOpts(opts, inOpts);
end

%Set opts for sumNucHist
snhop = opts;
snhop.verbose = 0;

%Add options for opts.pdd
if opts.pdd
    snhop.binsz = 2;
%     snhop.roi = [0 800]; %Make sure binsz divides diff(roi);
    snhop.fil = 10;
end


len = length(inst);
xs = cell(1,len);
ys = cell(1,len);
es = cell(1,len);
lgn = cell(1,len);
instcopy = inst;
for i = 1:len
    
    if opts.pdd
        tmp = inst(i).pdd; %cellfun(@(x) x + 0.5, inst(i).pdd, 'Un', 0);
    else
        tmp = inst(i).drA;
    end
    
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
    
    %Add crossing RTH
    instcopy(i).drA = inst(i).drA(ki);
    
end

% plotNucHist_err(xs, ys, es); %Actually, errorbars are pretty small so eh. Also need to set errorbar width
plotNucHist(xs, ys, opts);
xlim([0 160])
ylim([0 4])
legend(lgn)
str1 = {' OnlyCross'};
str2 = {' OnlyPick'};
set(gcf, 'Name', ['ezFactPlot'  str1{logical(opts.onlycross)} str2{logical(opts.onlypick)} ] )

procFran_cross(instcopy)
