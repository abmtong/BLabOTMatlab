function out = prepForDNAcycPweb2(nucseqs, nfokeep)
%Prep for input for DNAcycP webserver (https://cyclizability.stats.northwestern.edu/)
% DNAcycP predicts DNA cyclizibility, usually used as a proxy for flexibility

%Gives the entire sequence, remove some padding

if nargin < 2
    tfflip = 1;
end

%Process nucseqs: remove chrM
ki = find(strcmp({nucseqs.chr},'chrM'));
if ki
    nucseqs(ki) = [];
end
pad = 0;

%Concatenate nucseqs
seqs = [nucseqs.nucseq];
nfos = [nucseqs.nucnfo];

%Webserver has 20k bp max, so limit
maxn = floor( 2e4 / (length(seqs{1})-2*pad) );

%Get some nuc seqs
nnucmax = length(seqs);
nnuc = min( maxn, nnucmax );
%Do it randomly? Set an RNG seed?
s=rng; %Get current RNG
rng(0) %Set to arbitrary RNG
ki = randperm(nnucmax);
rng(s); %Revert RNG

%And extract
lseqs = cell(1, nnuc);
nseq = 0;
for i = 1:nnucmax
    
    %Flip if in (-), skip if in 0
    if tfflip
        switch nfos( ki(i) )
            case -1
                lseqs{i} = seqrcomplement( seqs{ki(i)}(1+pad:end-pad) );
            case 1
                lseqs{i} = seqs{ki(i)}(1+pad:end-pad);
            case 0
                continue
        end
    else
        lseqs{i} = seqs{ki(i)}(1+pad:end-pad);
    end
    nseq = nseq + 1;
    if nseq >= nnuc
        break
    end
end

%Combine to output
out = [lseqs{:}];