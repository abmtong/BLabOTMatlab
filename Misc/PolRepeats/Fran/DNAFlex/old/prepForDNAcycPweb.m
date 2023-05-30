function out = prepForDNAcycPweb(nucseqs, tfflip)
%Prep for input for DNAcycP webserver (https://cyclizability.stats.northwestern.edu/)
% DNAcycP predicts DNA cyclizibility, usually used as a proxy for flexibility
%Output is a 20kb string (max input for webserver), 200 * [50bp left arm , 50bp right arm]

%Will take first 50 and last 50 bp, so alter the padding for getNucSeqs to what you want
pad = 0; %Remove first N nucs

%Whether to flip based on gene loc
if tfflip
    tfflip = 1;
end

%Process nucseqs: remove chrM
ki = find(strcmp({nucseqs.chr},'chrM'));
if ki
    nucseqs(ki) = [];
end

%Concatenate nucseqs
seqs = [nucseqs.nucseq]; %Sequence
nfos = [nucseqs.nucnfo]; %Gene info (-, 0, +)

%Get some nuc seqs
nnucmax = length(seqs);
nnuc = min( 200, nnucmax );
%Do it randomly? Set an RNG seed?
s=rng; %Get current RNG
rng(0) %Set to arbitrary RNG
ki = randperm(nnucmax);
rng(s); %Revert RNG

%And extract
lseqs = cell(1, nnuc);
rseqs = cell(1, nnuc);
nseq = 0;
for i = 1:nnucmax
    
    %Flip if in (-), skip if in 0
    if tfflip
        switch nfos( ki(i) )
            case -1
                lseqs{i} = seqrcomplement( seqs{ki(i)}(pad+(1:50)));
                rseqs{i} = seqrcomplement( seqs{ki(i)}( end + (-49:0) - pad ));
            case 1
                lseqs{i} = seqs{ki(i)}(pad+(1:50));
                rseqs{i} = seqs{ki(i)}( end + (-49:0) - pad );
            case 0
                continue
        end
    else
        lseqs{i} = seqs{ki(i)}(pad+(1:50));
        rseqs{i} = seqs{ki(i)}( end + (-49:0) - pad );
    end
    nseq = nseq + 1;
    if nseq >= nnuc
        break
    end
end

%Combine to output
out = [lseqs; rseqs];
out = [out{:}];