function out = formatSeq(str, seqcell)

%Translates sequence string '%d %d:%d | %d %d:%d etc.' into a set of sequences
% May need to handle strand breaks?

inds = textscan(str, '%d %d:%d', 'Delimiter', '|');
inds = [inds{:}]; %a nx3 matrix

%Want Sequence A : Sequence B : Sequence C , to match what the Colab notebook wants
out = seqcell{inds(1, 1)}(inds(1, 2):inds(1, 3));
for i = 2:size(inds, 1)
    out = [out ':' seqcell{inds(i, 1)}(inds(i, 2):inds(i, 3)) ]; %#ok<AGROW>
end
