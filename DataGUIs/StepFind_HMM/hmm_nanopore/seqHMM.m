function out = seqHMM(tr, inOpts)
%Sequences a nanopore trace by HMM model

%% Options struct
opts.nb = 4; %Number of bases (ATGC)
opts.nc = 4; %Number of bases in channel ('codon')
%Transition matrix - transition probabilities.
opts.trnsprb = 1e-4; %Transition probability. Use either ntrs/npts to sequence, or a very small value (1e-10 ish) to try to optimize mu values
opts.btprb = 0; %Backtrack probability. Use zero to ignore backtracks
%Transition matrix - allowed transitions. Choose up to one.
opts.okstates = []; %Allowed states.
opts.okseq = []; %Allowed transitions. If we know the sequence, cleans up the trns mtrx. Might be too strong a bias?

%Load state values (current at each codon) from Laszlo, Nat Biotechnol. 2014 (doi:10.1038/nbt.2950)
if exist('muref.mat', 'file');
    tmpmu = load('muref.mat');
    opts.mu = tmpmu.mu_debru(:)';
else
    opts.mu = 1:256;
end
opts.sig = sqrt(estimateNoise(tr));
opts.verbose = 1;

%For each option below, use either the default or the one in mdl
if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%% Unwrap options
nb = opts.nb;
nc = opts.nc;
trnsprb = opts.trnsprb;
btprb = opts.btprb;
mu = opts.mu;
sig = opts.sig;

%Sanity check: (trnsprb + btprb) * nc < 1, so the do nothing probability is nonzero
assert( (trnsprb + btprb) * nc < 1, 'Transition/backtrack probability too high' )

stT = tic;

%% Transition matrix
len = length(tr); %Length of trace
ns = nb^nc; %Number of states
%The transition matrix has ns^2 elements (256x256=65k) but only ns*nb (256x4=1k) nonzero values, so solvable
%Generate sparse transition matrix by i,j,v vectors (see >>doc sparse)
%Diagonal (no transition)
spi1 = 1:ns;
spj1 = 1:ns;
spv1 = ones(1,ns) * (1 - trnsprb*nb - btprb*nb);
%Transitions
spi2 = repmat(1:ns, [nb,1]);
spj2 = zeros(nb,ns);
for i = 1:ns
    cdn = num2cdn(i, nc); %Every initial codon WXYZ can transition to XYZN
    spj2(:,i) = arrayfun(@(x) cdn2num([cdn(2:nc) x]), 1:nb);
end
spv2 = ones(1,ns*nb)*trnsprb;
%Backtracks
spi3 = repmat(1:ns, [nb,1]);
spj3 = zeros(nb,ns);
for i = 1:ns
    cdn = num2cdn(i); %Every initial codon WXYZ can backtrack to NWXY
    spj3(:,i) = arrayfun(@(x) cdn2num([x cdn(1:nc-1)]), 1:nb);
end
spv3 = ones(1,ns*nb)*btprb;
%Deal with disallowed transitions of opts.okstates is passed
if ~isempty(opts.okstates)
    oks = opts.okstates;
    %Zero out spv's of disallowed transitions
    kii2 = false(size(spi2));
    kij2 = false(size(spi2));
    kii3 = false(size(spi3));
    kij3 = false(size(spi3));
    for i = oks
        %Make sure spi and spj are both ok. spi == oks | spj == oks in trns/bts, add back trnsprb to spj1. Keep diagonal 1.
        kii2 = kii2 | spi2 == i;
        kij2 = kij2 | spj2 == i;
        kii3 = kii3 | spi3 == i;
        kij3 = kij3 | spj3 == i;
    end
    %Values to omit are ~ the okay ones
    oi2 = ~ (kii2 & kij2);
    oi3 = ~ (kii3 & kij3);
    %Zero out spv2/3
    spv2(oi2) = 0;
    spv3(oi3) = 0;
    %Add back to spv1
    spv1 = spv1 + sum(oi2,1)*opts.trnsprb;
    spv1 = spv1 + sum(oi3,1)*opts.btprb;
elseif ~isempty(opts.okseq)
    %Check if okseq is a nt seq or a state seq
    if ischar(opts.okseq)
        okseq = seq2st(opts.okseq);
    else
        okseq = opts.okseq;
    end
    %Zero out spv's of disallowed transitions
    kii2 = false(size(spi2));
    kii3 = false(size(spi3));
    for i = 1:length(okseq)-1;
        %Make sure spi and spj are both ok. spi == oks | spj == oks in trns/bts, add back trnsprb to spj1. Keep diagonal 1.
        kii2 = kii2 | spi2 == okseq(i) & spj2 == okseq(i+1);
        kii3 = kii3 | spi3 == okseq(i+1) & spj3 == okseq(i);
    end
    %Values to omit are ~ the okay ones
    oi2 = ~ kii2;
    oi3 = ~ kii3;
    %Zero out spv2/3
    spv2(oi2) = 0;
    spv3(oi3) = 0;
    %Add back to spv1
    spv1 = spv1 + sum(oi2,1)*opts.trnsprb;
    spv1 = spv1 + sum(oi3,1)*opts.btprb;
end
%Assemble the transition matrix
a = sparse([spi1 spi2(:)' spi3(:)'], [spj1 spj2(:)' spj3(:)'], [spv1 spv2(:)' spv3(:)']);

%% Assign the path via Vitterbi
%Gaussian pdf shortcut. Works with scalar sig and array sig (size = 1xns)
npdf = @(x) normpdf(mu, tr(x), sig);

%Initial state guess
pi = npdf(1);
%Place to save vitterbi paths
vitdp = zeros(len-1, ns); %vitdp(t,p) = q means the best way to get to (t+1,p) is from (t,q)
%Vitterbi score (probability)
vitsc = pi .* npdf(1);
for i = 1:len-1
    %Calculate proposed paths, take best
    [tsc, tvitdp] = max( bsxfun( @times, a, vitsc'), [], 1);
    %Apply score, apply npdf, renormalize
    vitsc = tsc .* npdf(i+1) / sum(tsc);
    %Save best paths
    vitdp(i, :) = tvitdp;
end
%Assemble path via backtracking
st = zeros(1,len);
[~, st(len)] = max(vitsc);
for i = len-1:-1:1
    st(i) = vitdp(i,st(i+1));
end

%% Get sequence
%Find changes in state
[~, me] = tra2ind(st);
%Translate each codon into its nucleotides
seqtmp = arrayfun(@(x)num2cdn(x,nc), me, 'Un', 0);

seq = seqtmp{1};
cdn = seqtmp{1};
kept = true(1,length(seqtmp));
for i = 2:length(seqtmp)
    newcdn = seqtmp{i};
    %Check if fwd or rev
    if all(cdn(2:end) == newcdn(1:end-1))
        %Assign if fwd
        seq = [seq newcdn(end)]; %#ok<AGROW>
        cdn = newcdn;
    else
        %Remove if rev
        seq = seq(1:end-1);
        kept(i) = false;
        kept(find(kept(1:i), 1, 'last')) = false;
        cdn = newcdn;
    end %Some issues handling backtracks, i.e. not respecting 'previous' values correctly. Non-markovian to add, though.
    %Best I can do is handle by checking if improper backtracks occur and just ignoring that data
end

%below was no-bt code
% seqtmp = reshape([seqtmp{:}], 4, [])';
% %Extract sequence by getting every nb-th value **Assumes no backtracking right now**
% seq = seqtmp([1:nb-1 nb:nb:end]);

%% Assemble output, plot results
cdns = 'ATGC';
out.fit = mu(st); %Fit trace
out.fiti = st; %Fit trace indicies
out.seq = seq; %Sequence, in index
out.seqn = cdns(seq); %Sequence, in text
out.opts = opts; %Options
out.kept = kept; %Which states were kept in sequence

if opts.verbose == 1
    plotSeq(tr, mu, st, kept) %Plot
elseif opts.verbose == 2
    %Just print an update line
    fprintf('seqHMM found a %dnt sequence in %0.2fs.\n', length(seq), toc(stT))
end

%To turn outstr back into ids, do:
%{
[~, ic, ia] = unique(['ATGC' outstr]); %Append ATGC to set @unique order
ids = ic(ia); %Get unique indicies, in given order
ids = ids(5:end); %Remove the appended 'ATGC' [ids(1:4) should equal 1:4]
%}


%Updating mu using a known sequence actually doesn't require calculating gamma, so just skip
%{
    %Precalculate npdf for each point and state
    npdfp = zeros(len,ns);
    for i = 1:len
        npdfp(i,:) = normpdf(mu, tr(i), sig);
    end
    %% Calculate gamma (probability of being at each state at each point)
    %Calculate alpha
    al = zeros(len,ns);
    scal = zeros(1,len);
    al(1,:) = pi .* npdfp(1,:);
    scal(1) = sum(al(1,:));
    al(1,:) = al(1,:)/scal(1);
    for t = 1:len-1
        for j = 1:ns
            temp = 0;
            for i = 1:ns
                temp = temp + al(t,i) * a(i,j);
            end
            al(t+1, j) = temp * npdfp(t+1,j);
        end
        scal(t+1) = sum(al(t+1,:));
        al(t+1,:) = al(t+1,:)/scal(t+1);
    end
    %Calculate beta
    be = zeros(len,ns);
    be(len,:) = ones(1,ns);
    be(len,:) = be(len,:) / scal(len);
    for t = len-1:-1:1
        for i = 1:ns
            temp = 0;
            for j = 1:ns
                temp = temp + be(t+1, j) * a(i,j) * npdfp(t+1,j);
            end
            be(t,i) = temp / scal(t);
        end
    end
    %Gamma = alpha * beta
    ga = al .* be;
%}

end