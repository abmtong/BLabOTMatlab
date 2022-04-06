function out = fmtResTimes(inst, inOpts)
%Formats a data struct for plotting per-bp residence times
% Plot with plotResTimes(out, [positions])

%inst = struct('group1', {traces1}, 'group2', {traces2}, etc.)
% Inputs are already rulerAlign'ed

%Handle plotting in a different function, where the output of this can be used to show per-residue dist.s

%Repeat options
opts.per = 68;
opts.nrep = 8;
opts.Fs = 1e3;
opts.histfil = 20; %pts, half width (x2+1)

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%RTH opts
histopts.per = opts.per;
histopts.normmeth = 2; %s/bp
histopts.Fs = opts.Fs;
histopts.fil = opts.histfil;
histopts.binsz = 1; %Let's force this to one for now
histopts.verbose = 0;

%Generate RTH for each group
fns = fieldnames(inst);
len = length(fns);
for i = 1:len
    [~, tx, tys] = sumNucHist(inst.(fns{i}), histopts);
    
    %Split into 3 sections: pre-repeat, repeats, and post-repeats
    
    %Sum across repeats
    %Extract repeat section from raws{i}...
    tmp = [tys{:}];
    i0 = find(tx >= 0, 1, 'first');
    
    pre.x = tx(1:i0-1);
    pre.y = mat2cell(tmp(1:i0-1, :), ones(1, i0-1))';
    rpt.x = tx(i0 + (0:opts.per-1));
    tmprpt = tmp(i0 + (0:opts.per*opts.nrep-1), :);
    tmprpt = reshape(tmprpt, opts.per, []);
    rpt.y = mat2cell( tmprpt , ones(1, opts.per) )';
    ipos = i0 + opts.per*opts.nrep;
    pos.x = tx(ipos : end);
    pos.y = mat2cell(tmp(ipos:end, :), ones(1, size(tmp,1)-ipos+1))';
    
    out.(fns{i}).pre = pre;
    out.(fns{i}).rpt = rpt;
    out.(fns{i}).pos = pos;
end

