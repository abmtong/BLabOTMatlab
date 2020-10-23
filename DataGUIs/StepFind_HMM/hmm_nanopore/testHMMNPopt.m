function out = testHMMNPopt(sd)
if nargin < 1
    sd = [];
end

%Now instead use the 'reference' values agains the 'debru' values
ref = load('muref.mat');
mu = ref.mu_ref;

%OK it's been proven this works pretty well for these two sets
%Let's make it harder

%Replace some values with random other values, to simulate it being 'mostly right' but with some very wrong
ifk = randperm(256, 10);
ife = randperm(256, 10);
mu(ifk) = mu(ife);
mu = mu + randn(1, 256) * 1; %Add 2pN noise

len = 1e4;
nt = 'ATGC';
stT = tic;

%Repeat a few times. This is usually a ~100nt trace, that ~1/2 aligns well enough (50nt/trace)
%Go for 10x coverage (~500 traces)
niter = 500;
opts.verbose = 2;
opts.trnsprb = 1e-20;
opts.minlen = 8;

newmu = cell(1,niter);
parfor i = 1:niter;
    %Simulate trace
    [tr, seq, indmea] = simtracenp([], sd, mu);
    
    %Find cutoff for seq
    ico = find(indmea{1} > len, 1, 'first');
    if isempty(ico)
        ico = length(seq);
    end
    nseq = nt(seq(1: min(ico-1+3, length(seq)) ));
    
    % The sequence is pretty close IF we make trnsprb really small (so poor fitting is taken over more trns)
    %The actual value should be: If we want to tolerate a difference of S*SD on average, with the average dwell time of N pts, then (roughly):
    % 2 trns * P(Z=0)^npts < 1 trns * P(Z=S)^npts; thus 1trns < P(Z=S/Z=0)^npts , for S=1, Z=100, trns < 1e-22
    res = seqHMM(tr(1:len), opts);
    
    % Get mu update
    newmu{i} = seqHMMp2(tr, res, nseq, opts);
end

out = seqHMMp3(newmu);

newmu = out(:,1)';
%Plot start and final values (where they started [red] and where they should be going [green]
ax=gca;
plot(ax, ref.mu_debru, (1:256)+.3, 'ro')
plot(ax, ref.mu_ref, (1:256)-.3, 'go')
kicl= abs(newmu-ref.mu_debru) > abs(newmu-ref.mu_ref);
dst = abs(newmu-ref.mu_ref);
ki1 = dst < 1;
ki2 = dst < 0.5;
ki3 = dst < 0.1;
fprintf('%d traces analyzed in %0.2fs.\n', niter, toc(stT))
fprintf('%d/256 values are closer or were already good, %d/256 are within 1pA, %d/256 within 0.5pA, %d/256 within 0.1pA\n', sum(kicl|ki3) , sum(ki1), sum(ki2), sum(ki3))

