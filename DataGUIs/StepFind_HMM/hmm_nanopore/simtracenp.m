function [out, inseq, raw] = simtracenp(inseq, innoi, inmu, indw)

if nargin < 4
    %Dwell length, Erlang distribution [meanpts, order]
    indw = [100, 1];
    %Paper shows steps are ~0.1s, let's use Fs = 1kHz
end

if nargin < 3 || isempty(inmu)
    inmu = load('muref.mat');
    inmu = inmu.mu_debru;
end

if nargin < 2 || isempty(innoi)
    innoi = 1; %Rough estimate of noise 
    %Paper shows noise@5kHz is ~2pA or so? So let's do @1kHz, noise ~ 1pA
end

if nargin < 1 || isempty(inseq)
    %Generate random codon sequence
    inseq = randi(4, 1, 200);
    %Remove >4-tuples, since those can't be discerned
    %Easiest way (?) is to use strfind
    nt = 'ATGC';
    seqn = nt(inseq);
    ai = strfind(seqn, 'AAAAA');
    ti = strfind(seqn, 'TTTTT');
    gi = strfind(seqn, 'GGGGG');
    ci = strfind(seqn, 'CCCCC');
    inseq([ai ti gi ci]) = [];
end

%Get state sequence from codon sequence
cdnseq = seq2st(inseq, inmu);
len = length(cdnseq);

%Get length of each dwell (Erlang distributed, Poisson if indw(2) == 1)
if length(indw) == 1
    indw = [indw 1];
end
dwbar = indw(1)/indw(2); %Points
nmin = indw(2);
ndw = ceil(sum(exprnd(dwbar, nmin, len),1));

%Assemble trace with ind2tra
ind = [1 cumsum(ndw)];
tr = ind2tra(ind, cdnseq);

%Add noise
out = tr + randn(size(tr)) * innoi;

raw = { ind, cdnseq };