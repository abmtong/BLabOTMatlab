function out = procFran_pdd_rth(inst, opts)
%Analyze the pdd traces

%BACKUP of old p2, unfinished, but should create an RTH?

opts.onlycross = 0; %Only crossers?
opts.onlypick = 0; %Only picked traces?

opts.Fs = 1e3;
opts.fil = 2; %Filter half-width (fil*2+1 bp)

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(inst);
% outraw = cell(1, len);
%Calculate RTHs from traces fit in p1
for i = 1:len
    tmptr = inst(i).pdd;
    
    %Crop NaNs = padding to match data pre-roi crop
    tmptr = tmptr( ~isnan( tmptr ) );
    
    %Select only crossers or only picked
    ki = true(size(tmptr));
    if opts.onlycross
        ki = ki & inst(i).tfc;
    end
    if opts.onlypick
        ki = ki & inst(i).tfpick;
    end
    tmptr = tmptr(ki);
    
    %Kill empty
    tmptr = tmptr( ~cellfun(@isempty, tmptr) );
    
    %Remove backtrakcs from trace
    tmptr = cellfun(@(x)removeTrBts(x,1), tmptr, 'Un', 0);
    
    %Convert to in, me's
    [in, me] = cellfun(@tra2ind, tmptr, 'Un', 0);
    dw = cellfun(@diff, in, 'Un', 0);
    
    %Get me range
    mmin = min( cellfun(@min, me) );
    mmax = max( cellfun(@max, me) );
    
    %Get median dwelltime
    %Filter
    dw = cellfun(@(x) windowFilter(@mean, x, opts.fil, 1), dw, 'Un', 0);
    
    rthx = mmin:mmax;
    hei = length(rthx);
    rthyraw = cell(1,hei);
    rthy = nan(1,hei);
    for j = 1:hei
        snp = cellfun(@(x,y) y(x == rthx(j)), me, dw, 'Un', 0);
        snp = [snp{:}];
        rthy(j) = median(snp);
        rthyraw{j} = snp;
    end
    %Convert pts to time
    rthy = rthy / opts.Fs;
    inst(i).pddrth = [rthx(:) rthy(:)];
end

%Plot
figure('Name', 'procFran_pddp2')
hold on
for i = 1:length(inst)
    plot(inst(i).pddrth(:,1),inst(i).pddrth(:,2))
end
legend({inst.nam})

out = inst;


