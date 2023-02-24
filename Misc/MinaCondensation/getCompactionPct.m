function [out, outraw] = getCompactionPct(dat, fns, inOpts)


opts.fil = 100; %Match the filter+dec by 200 pts for plotting
opts.dnalen = 6256; %DNA length, amt for 100% compaction

if nargin > 2
    opts = handleOpts(opts, inOpts);
end


len = length(fns);
outraw = cell(1, len);
out = zeros( 7, len);
for i = 1:len
    %get datlo
    tmp = dat.(fns{i}).lo;
    
    %Filter
    tmpf = windowFilter(@mean, tmp, opts.fil, 1);
    
    %Use minimum value as compaction pct.
    maxcomp = cellfun(@min, tmpf);
    
    maxcomp = 1- maxcomp/opts.dnalen;
    
    outraw{i} = maxcomp;
    out(:, i) = [mean(maxcomp) median(maxcomp) std(maxcomp) length(maxcomp) std(maxcomp)/sqrt(length(maxcomp)) prctile(maxcomp, 25) prctile(maxcomp, 75)];
end

%Output table of mean, SD, N, SEM, 