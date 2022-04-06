function [out, outdiff] = rulerAlignV2p2V2(tra, inOpts)
%After rulerAlignV2, check for repeat shifting up/down
%So, align against the consensus histogram instead of itself

%Maybe also align with outside regions? Those ~should~ also be seq-dep.

opts.alignmeth = 1; %1 = just repeats, 2 = whole RTH
opts.normmeth = 0; %0 = none, 1 = per-bp norm'zation

opts.binsz = 0.5;
opts.per = 258; %Just need period
% opts.persch = [-1 0 1]; %Compare these period multiples. Or just do all?
opts.nrep = 8;
opts.Fs = 1e3;
opts.histfil = 10;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Generate consensus histogram
histopts.per = opts.per;
histopts.normmeth = 2; %s/bp
histopts.Fs = opts.Fs;
histopts.fil = opts.histfil;
histopts.binsz = opts.binsz;
histopts.roi = [-inf inf];
histopts.verbose = 0;
[hy, hx] = sumNucHist(tra, histopts);
nwid = opts.per/opts.binsz;
%Make consensus repeat histogram
i0 = find(hx >= 0, 1, 'first');
tmp = reshape(hy( i0+(0:nwid*opts.nrep-1) ), nwid, opts.nrep);
avgrth = median(tmp, 2)';

len = length(tra);
outdiff = zeros(1,len);
% hei = length(opts.persch);

for i = 1:len
    %Generate this trace's RTH
    [ty, tx] = sumNucHist(tra{i}, histopts);
   
    %Get search window: how many per in each direction
    minx = ceil ( min(tx) / opts.per);
    maxx = floor( max(tx) / opts.per)-1;
    
    %Label these repeats, with 0-7 being the 'regular' ones
    srch = minx:maxx;
    nsrch = length(srch);
    scrs = zeros(1, nsrch);
    %Score likeness of each of these repeats with the consensus one
    for j = 1:nsrch
        %Get the segment
        i0 = find(tx >= opts.per * srch(j),1, 'first');
        tmpj = ty(i0 + (0:nwid-1));
        %Take cauchy-schwarz distance between these two curves
        scrs(j) = sum( tmpj .* avgrth ) / sqrt( sum(tmpj.^2) * sum( avgrth.^2 ) );
    end
    
    %Take best run of nrep scores. Mean? Median?
    sumscr = filter(ones(1,opts.nrep), 1, scrs);
    sumscr = sumscr(opts.nrep:end);
    [~, maxi] = max(sumscr);
    if isempty(maxi)
        outdiff(i) = nan;
    else
        outdiff(i) = srch(maxi) * opts.per;
    end
end

out = cellfun(@(x,y) x - y, tra, num2cell(outdiff), 'Un', 0);

%For each moved one...
ki = outdiff(i) ~= 0;
for i = 1:len
    if ki(i)
        
    end
end







