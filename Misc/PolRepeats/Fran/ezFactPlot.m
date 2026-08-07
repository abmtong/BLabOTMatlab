function ezFactPlot(inst, varargin)
%Outputs of ezFactAnalyze

opts.onlycross = 1; %Only crossers?
opts.onlypick = 1; %Only picked traces? (add field of .tfpick)
opts.pdd = 0; %Use PDD for RTH?

%More special data sorting options
opts.tendmax = inf; %tcrraw(2) (absolute time to cross nuc) max, seconds
opts.tcrbins = [0 inf]; %tcr bins, e.g. do [0 100 inf] to separate 0-100 and 100+ t_cross

opts.Fs = 1e3;
opts.binsz = 0.5;

%Fluorescence
opts.plotfl = 1; %Do fluorescence or not, if data is found


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
ntbin = length(opts.tcrbins)-1;
xs = cell(ntbin,len);
ys = cell(ntbin,len);
es = cell(ntbin,len);
lgn = cell(ntbin,len);
instcopy = inst;
for i = 1:len
    
    if opts.pdd
        tmp = inst(i).pdd; %cellfun(@(x) x + 0.5, inst(i).pdd, 'Un', 0);
    else
        tmp = inst(i).drA;
    end
    
    ki = true(size(tmp)); 
    if opts.onlycross && isfield(inst, 'tfc')
        ki = ki & logical(inst(i).tfc);
    end
    if opts.onlypick && isfield(inst, 'tfpick')
        ki = ki & logical(inst(i).tfpick);
    end
    if opts.tendmax < inf && isfield(inst, 'tcrraw')
        ki = ki & (inst(i).tcrraw(:,2)' < opts.tendmax);
    end
    
    for j = 1:ntbin
        %If default tcrbins = [0 inf], just ignore
        if isequal(opts.tcrbins, [0 inf])
            [ys{j,i}, xs{j,i}, yraw] = sumNucHist(tmp(ki), snhop);
            es{j,i} = std([yraw{:}], [], 2, 'omitnan')/opts.Fs/opts.binsz;
            
            lgn{j,i} = sprintf('%s, N=%d', inst(i).nam, sum(ki));

        else %Handle tcrbins
            ki2 = ki & (inst(i).tcr(:)' > opts.tcrbins(j)) & (inst(i).tcr(:)' <= opts.tcrbins(j+1));
            [ys{j,i}, xs{j,i}, yraw] = sumNucHist(tmp(ki2), snhop);
            es{j,i} = std([yraw{:}], [], 2, 'omitnan')/opts.Fs/opts.binsz;
            
            %Legend, add time range
            lgn{j,i} = sprintf('%s, %0.0f-%0.0fs, N=%d', inst(i).nam, opts.tcrbins(j), opts.tcrbins(j+1), sum(ki2));
        end
    end
    %Edit instcopy for crossing time
    instcopy(i).drA = inst(i).drA(ki);
    instcopy(i).tcr = inst(i).tcr(ki);
    

end

%Un-matrix data
ys = ys(:);
xs = xs(:);
es = es(:);
lgn = lgn(:);

% plotNucHist_err(xs, ys, es); %Actually, errorbars are pretty small so eh. Also need to set errorbar width
plotNucHist(xs, ys, opts);
xlim([0 160])
ylim([0 4])
legend(lgn)
str1 = {' OnlyCross'};
str2 = {' OnlyPick'};
set(gcf, 'Name', ['ezFactPlot'  str1{logical(opts.onlycross)} str2{logical(opts.onlypick)} ] )

procFran_cross(instcopy)
