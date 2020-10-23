function out = testHMMNP(sd)
if nargin < 1
    sd = [];
end

[tr, seq, indmea] = simtracenp([], sd);
len = 1e4;

nt = 'ATGC';

%Find cutoff for seq
ico = find(indmea{1} > len, 1, 'first');
if isempty(ico)
    ico = length(seq);
end

nseq = nt(seq(1: min(ico-1+3, length(seq)) ));
tic
hseq = seqHMM(tr(1:len));
hnseq = nt(hseq.seq);
toc

nseq, hnseq