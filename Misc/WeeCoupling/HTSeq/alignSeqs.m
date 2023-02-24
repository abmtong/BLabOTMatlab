function [out, outraw] = alignSeqs(inst)

%Input: struct with field seqs (sequence) post-UMI trim


if length(inst) > 1
    [out, outraw] = arrayfun(@alignSeqs, inst, 'Un', 0);
    return
end

seqs = inst.seqs;

%Create consensus sequence (take median over each site?

%Let's pad reads with Xs (sequencing data uses N for undetermined base)
maxlen = max ( cellfun(@length, seqs) );
tgt = repmat('X', 1, maxlen);
seqs = cellfun(@(x) [ x repmat('X', 1, maxlen-length(x))], seqs, 'Un', 0);

%Create consensus sequence
tgt = mode( reshape(  [seqs{:}], maxlen, [] ), 2 )';

%Find differences for each transcript
%use @localalign

nseq = length(seqs);
outraw = cell(1,nseq);
nerror = zeros(3,nseq);
for i = 1:nseq
    %Align with @localalign
    la = localalign( tgt, seqs{i} , 'alphabet', 'NT', 'numaln', 1);
    
    %Detect SNPs or INDELs
    %la.Alignment{1} is a text alignment, e.g.:
    %{
    ATGCAATGC
    |||| ||||
    ATGC-ATGC
    %}
    %Simple: insertion is a - in the top row, deletion is a - in the bottom row
    %Sum of SNP + INS + DEL is the number of missing bars in the ctr row
    %Assume alignment is 'good enough' that we can just count them all

    tmp = la.Alignment{1};
    
    %Lets just count for now and figure out how to get stats later
    nins = sum( '-' == tmp(1,:));
    ndel = sum( '-' == tmp(3,:));
    nsnp = sum( ' ' == tmp(2,:)) - nins - ndel;
    
    outraw{i} = tmp;
    nerror(:,i) = [nsnp; nins; ndel];
end

out = nerror;