function [out, outraw] = seqHMMp2b(tr, mu, res, trueseq, inOpts)
%Get the section aligned in seqHMM, then either fit N steps to it (K-V) or do prgHMM on it with the aligned sequence ...

opts.method = 2; %1=prgHMM, 2=K-V
opts.verbose = 0;
opts.nc = 4;
opts.sig = 1;
opts.trnsprb = 1e-10;

if nargin > 4
    opts = handleOpts(opts, inOpts);
end

nc = opts.nc;

%Align sequences
la = localalign(trueseq, res.seqn, 'Alphabet', 'nt', 'GapOpen', 8); %Should consider increasing GapOpenValue since we dont want gaps
aln = la.Alignment{1};

%We want at least the edge codons to be 'correct', meaning 4-length alignment.

%Find runs of 4. Use strfind
bars = aln(2,:);
sf = strfind(bars, '||||');
%If fewer than 2 runs exist, can't continue
if length(sf)<2
    out = [];
end

%Adjust indicies to match the sequence by removing '-'s and adding Start index
sf1 = la.Start(1)-1+ [ sf(1) - sum( aln(1,1:sf(1)) == '-' ), sf(end) - sum( aln( 1,1:sf(end) ) == '-'  ) ];
sf2 = la.Start(2)-1+ [ sf(1) - sum( aln(3,1:sf(1)) == '-' ), sf(end) - sum( aln( 3,1:sf(end) ) == '-'  ) ];

%Get aligned sequence
tseqcrp = trueseq(sf1(1):sf1(2));

%Get data in tr of the kept nucleotides
[in, ~] = tra2ind(res.fiti);
trcrp = tr( in(nc -1 + (sf2(1))):in(sf2(2)) );

%Process various ways
% Goal is to output in, st with staircase ind/ states
switch opts.method
    case 1 %prgHMM, not great right now
        %Fit this region to the theoretical staircase
        ph = prgHMM(trcrp, mu, tseqcrp, opts);
        in = tra2ind(ph);
        st = seq2st(tseqcrp, 1:256);
    case 2
        [in, ~, ph] = AFindStepsV5(trcrp, 0, length(tseqcrp)-nc, 0);
        st = seq2st(tseqcrp, 1:256);
end
%Extract values
%Do I want to exclude some here? Or do like Mean+SD and weight by 1/SEM^2 (weight should be 1/var) on updateMu?


val = ind2mea(in, trcrp);
nn = cellfun(@diff, in);

%Get STDs
nval = length(st);
valsd = zeros(1,nval);
for i = 1:nval
    valsd(i) = std(trcrp(in(i):in(i+1)-1));
end

out = [st' (val./ sqrt(nn))' nn']; %Mean, SEM, N

%Fit results
outraw.fit = ph; %Raw fitting results
outraw.trind = sf2; %Indicies of trace that were used
outraw.seq = tseqcrp; %Sequence fit to

end
