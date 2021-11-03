function out = findHairpins(seq, inOpts)


%For a given sequence, finds hairpins

%In MTB, pause sequences seem to only be from hairpins, as eg the sequence-dependent (eg G-10Y-1G+1) pausing in Ecoli is not observed here

%So, can we scrub the genome for hairpins?

%From Shixin's screen, we see a bunch of terminator hairpins as ~20nt hairpins (3-4 nt loop, some mismatches/gaps ok)

%So how to do this? For every nucleotide, align the +30 vs. the -30, and check if they are ok enough ?



opts.wid = 30; %nt on each side, roughly max hairpin size
opts.nloop = 3:5; %Acceptable number of loop residues
opts.minscr = 10; %Required score to save. Score = hairpin length - 3*gaps

if nargin > 1
    opts = handleOpts(opts,inOpts);
end


%This doesn't handle bulges, whatever (gaps ok though)

%Convert sequence to ACGT = 1234 (do so for alphabetic + pairs sum to 5)
isA = seq == 'A';
isT = seq == 'T';
isC = seq == 'C';
isG = seq == 'G';

seqnum = 1*isA + 2*isC + 3*isG + 4*isT;
len = length(seqnum);
nloop = opts.nloop;
nl = length(nloop);
wid = opts.wid;
hpscr = zeros(nl,len-2*wid-max(nloop)); %Hairpin score
for i = 1:len-2*wid-max(nloop)
    %Grab the first wid seqs, reverse
    tmp = seqnum( i-1 + (wid:-1:1) );
    for j = 1:nl
        %Compare to next wid seqs
        tmpsum = tmp + seqnum( i-1 + nloop(j) + wid + (1:wid) );
        %Consider pairing as +1 score, gap as -3
        tmpscr = -3 * ones(1,wid) + 4 * (tmpsum == 5);
        %Take highest cumsum
        hpscr(j,i) = max(cumsum(tmpscr));
    end
end

%Save high scores
[lsz, loc] = find(hpscr >= opts.minscr);

rawscrs = arrayfun(@(x,y)hpscr(x,y), lsz, loc);
lsz = nloop(lsz);
out = [loc(:) lsz(:) rawscrs(:)];

[~, si] = sort(rawscrs);
out = out(si(end:-1:1),:);
%Hmm out right now is dependent on wid, should probably add wid [s






%For each site i from wid+1 to end-wid....
%Align i+1:i+wid to i-1:-1: i-wid
%Check whether this is a hairpin or not


%This seems very poor execution wise. Maybe a better 'quick n dirty' check would be better:
% Take complement of one leg, check for equality 

%Or we need a even rougher first screen

%Take a 25nt section, check it against the next +3 or +4 sites, save hits