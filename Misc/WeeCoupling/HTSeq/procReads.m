function out = procReads(inst, inOpts)
%Now process the input raw reads from the FASTA into sequences + UMIs

%Input: output of readFasta, struct with field seqs (sequences) and rids (read IDs)

%UMI info
opts.umist = 1; %Start index of UMI
opts.umisz = 14;%Length of UMI
%Filtering info
opts.minreadsz = 130; %Reject reads shorter than this amount
opts.minreadn = 3; %Reject transcripts with fewer than this many reads
opts.maxNs = inf; %Maximum number of Ns in the read

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if length(inst) > 1
    out = arrayfun(@(x)procReads(x,x.opts), inst);
    return
end


%Unwrap
seqs = inst.seqs;
rids = inst.rids;

%First do easy rejections: Short reads, rare reads, bad reads
readlen = cellfun(@length, seqs);
readn = cellfun(@length, rids);
nNs = cellfun(@(x) sum( x == 'N'), seqs);

%Apply cutoff
ki = readlen >= opts.minreadsz & readn >= opts.minreadn & nNs < opts.maxNs;
seqs = seqs(ki);
rids = rids(ki);
readlen = readlen(ki);
readn = readn(ki);
fprintf('%d transcripts (%0.1f%%) rejected by minimum cutoffs\n', sum(~ki), sum(~ki)/length(ki)*100)

%We need to group by UMI (to control for PCR errors) and maybe reject low read pop.s?

%Get UMI
umis = cellfun(@(x) x(opts.umist + (0: opts.umisz-1) ), seqs, 'Un', 0);

%Check for dupes with unique
umiun = unique(umis);
umicts = histcounts(categorical(umis),categorical(umiun));

dupeumi = find(umicts > 1);
tokill = cell(1,length(dupeumi));
for i = 1:length(dupeumi)
    %Get data that share this UMI
    thisumi = umiun{dupeumi(i)};
    dupeumiinds = find(strcmp(umis, thisumi));
    %Get their trace Ns
    dupeumins = readn(dupeumiinds);
    %Take the largest. Maybe make sure it's over a threshold, too?
    [~, maxi] = max(dupeumins);
    %Sanity check: Let's say that this is >90% , else warn
    pctcon = dupeumins(maxi) / sum(dupeumins);
    if pctcon < 0.9
        warning('Read for UMI %s was only %0.1f%% consensus', thisumi, pctcon * 100);
    end
    %And mark the other data for removal
    tmp = dupeumiinds;
    tmp(maxi)= [];
    tokill{i} = tmp;
end
tokill = [tokill{:}];
%Remove data from the matrices we care about
seqs(tokill) = [];
rids(tokill) = [];
readlen(tokill) = [];
readn(tokill) = [];
umis(tokill) = [];

%Remove UMI from seqs. Crop to end of UMI
seqs = cellfun(@(x) x( opts.umisz+opts.umist :end), seqs, 'Un', 0);

%Assemble output
out.seqs = seqs;
out.umis = umis;
out.rids = rids;



