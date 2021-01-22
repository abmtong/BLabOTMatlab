function [out, outraw] = seqHMMp2(tr, res, trueseq, inOpts)
%Update mu when the sequence is known.
%Input is trace, output of seqhmm, and options
%Output is raw {codon, current} values, unsorted (sort and consesus with a different app)

%Default options
opts.nc = 4;
opts.minlen = 8; %Random chance is 1/4^minlen, 
opts.verbose = 1;

if nargin > 3
    opts = handleOpts(opts, inOpts);
end

nc = opts.nc;
minlen = opts.minlen;

if nargin < 2 || isempty(res)
    res = seqHMM(tr, opts);
end

%% Align sequence, and only update mu with data having proper sequencing results
minlen = max(minlen, nc);  %Must be >= nc
%Local align with @localalign
la = localalign(trueseq, res.seqn, 'Alphabet', 'nt', 'GapOpen', 8); %Should consider increasing GapOpenValue since we dont want gaps
aln = la.Alignment{1};
%aln is a 3xn char array, e.g.
%{
GACGCATGAG-AACAGGCT--CTCGCA--AAACGCGA-C-ACCGGGCTA-TAG-TG-GGG-TTATAGGTACCGTC-CTAGATA-ATTTCTTGC
|| ||| |||  |||||||  |||| |  |||||||| | |||  |||| | | |       | | |||  | || |||| || |  || | |
GA-GCA-GAGCCACAGGCTGGCTCGGAGCAAACGCGACCAACCAAGCTATTGGCTATATACCTGTGGGTTGCATCACTAGGTATAGATCGTCC
%}
%So we need to find pipes in the middle row, that don't have dashes on the other rows

%Find all the pipes in the comparison channel
midok = aln(2,:) == '|';
%Separate into runs
edg = diff([0 midok 0]);
indSta = find(edg == 1);
indEnd = find(edg == -1)-1;
indLen = indEnd - indSta + 1;
iki = indLen >= minlen;
indSta = indSta(iki);
indEnd = indEnd(iki);
kidisp = false(1,size(aln,2)); %Hold which nucleotides were used, for plotting
kise = false(1, length(indSta)); %Which start/end indicies were used
kiseq = false(1,length(res.seqn)); %Which codons of sequence were ok. Also remove first nc due to codon length
%Note that the above codons are NOT (necessarily) the correct indicies: depends on la.Start(2) (the starting codon).
% Allocate the longest it can be, though, and account for later
%Check every run
for i = 1:length(indSta)
    inds = indSta(i):indEnd(i);
    %Ok if there's no dashes in either top or bottom sequence (Shouldnt this always be the case?)
    kise(i) = ~any(aln(1,inds) == '-') & ~any(aln(3,inds) == '-');
    %Update if ok
    if kise(i)
        kidisp(inds) = true; %Mark section as 'ok'
        kiseq(inds(nc:end) - sum(aln(3,1:indSta(i)) == '-')) = true; %Codons that would be all correct are nc:end of them; need to subtract '-' that are before
    end
end

%Print sequence alignment results
if opts.verbose == 1
    fprintf('True sequence aligned with the fit sequence:\n')
    fprintf('%s\n', aln(1,:)) %Line 1 of alignment
    fprintf('%s\n', aln(2,:)) %Line 2 of alignment
    fprintf('%s\n', aln(3,:)) %Line 3 of alignment
    yn = ' +';
    fprintf('%s\n', yn(kidisp+1)) %Line of kept sequence, with +'s where alignment is used
    fprintf('^Kept sequences\n');
elseif opts.verbose == 2
    %Just print an update line
    fprintf('Aligned %d/%d bases.\n', sum(kiseq), length(trueseq))
end
%% Update mu
%Update codons that are properly sequenced
% kiseq = kiseq(nc:end); %Chop first bits
kiseq = find(kiseq) + la.Start(2) - 1 - nc + 1; %Adjust for starting position and codon length
[in, mei] = tra2ind(res.fiti); %Get the fit trace [in, me] to get the trace segments
newmu = ind2mea(in, tr); %Get the experimental means
mei = mei(res.kept); %Adjust for backtracking
newmu = newmu(res.kept);
%Extract the state IDs and the currents
upst = mei(kiseq);
upmu = newmu(kiseq);
out = [upst(:) upmu(:)];

% %Sanity check: For Alan's current sequence, these codons should never be detected, error if they are [= bug found]
% nt = 'ATGC';
% forbid = [25    28    39    41    44    48    51    55    62    70    71    74    75    83    85    90    94    98   101   102   103   114   121   127   136   138   139   141   154   155   159   160   163   164   175   176   177   187   188   191   199   209   218   226   227   233   239   245   249   251];
% for i = 1:length(forbid)
%     if any(upst == forbid(i))
%         fprintf('Found state %s in Alan''s data, which is forbidden; data removed', nt(num2cdn (forbid(i))))
%         warning('MultiBTs found probably ?')
%         out = [];
%     end
% end
