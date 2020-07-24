function [score, scorecmp] = align(seq1, seq2)
%aligns two ATCG sequences by brute force; actual alignments will show up as a (hi for as-is, lo for complement) peak in score

len1 = length(seq1);
len2 = length(seq2);

%make seq1 longer than seq2
if len1 < len2
    tmp = seq2;
    seq2 = seq1;
    seq1 = tmp;
    tmp = len2;
    len2 = len1;
    len1 = len2;
end

len = len1 - len2 + 1;
score = zeros(1, len);
for i = 1:len
    score(i) = sum( seq2 == seq1(i:i+len2-1));
end
score = score / len2;

if nargout > 1
    scorecmp = align(seq1, compl(seq2));
end