function out = prgHMM(tr, mu, seq, inOpts)
%Progression HMM : Forces the transitions determined by seq

opts.nc = 4; %Length of codon
opts.nb = 4; %Number of bases
opts.sig = []; %SD noise
opts.trnsprb = 1e-5;
opts.btprb = 0;

if nargin > 3
    opts = handleOpts(opts, inOpts);
end

nc = opts.nc;
nb = opts.nb;
trnsprb = opts.trnsprb;
btprb = opts.btprb;

if isempty(mu)
    mu = load('muref.mat');
    mu = mu.mu_debru;
end

if isempty(opts.sig)
    sig = sqrt(estimateNoise(tr,2));
else
    sig = opts.sig;
end
    
%Change seq to char, if passed as index
if ~ischar(seq)
    nt = 'ATGC';
    seq = nt(seq);
    %Below code does the opposite (char > ind)
%     [~, ic, ia] = unique(['ATGC' seq]); %Append ATGC to set @unique order
%     ids = ic(ia); %Get unique indicies, in given order
%     seq = ids(5:end)'; %Remove the appended 'ATGC' [ids(1:4) should equal 1:4]
end


%Generate state vector
clen = length(seq)-nc+1;
seqmu = seq2st(seq, mu);

%Generate transition matrix [sparse, IJV syntax]

%Diagonal
spi1 = 1:clen;
spj1 = 1:clen;
spv1 = ones(1,clen) - trnsprb - btprb;
spv1(1) = 1 - trnsprb; %Deal with first value (no bts)
spv1(end) = 1 - btprb; %Deal with last value (no trns)

%Translocations
spi2 = 2:clen;
spj2 = 1:clen-1;
spv2 = ones(1,clen-1)*trnsprb;

%Backtracks
spi3 = 1:clen-1;
spj3 = 2:clen;
spv3 = ones(1,clen-1)*btprb;

a = sparse([spi1 spi2 spi3], [spj1 spj2 spj3], [spv1 spv2 spv3]);

%Solve with stateHMMV2?
%Fields: ns a mu sig pi

inmdl.a = a;
inmdl.ns = clen;
inmdl.mu = seqmu;
inmdl.sig = sig;

out = fitVitterbi(tr, inmdl);

