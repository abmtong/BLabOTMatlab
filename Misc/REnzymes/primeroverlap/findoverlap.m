function [out, outlen] = findoverlap(seq1, seq2, dir)
%search for overlap of seq2 in seq1
if nargin < 3
    dir = 1;
end
%minimum overlap of say 10nt
minovl = 5;

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
if dir %chop from left end - for searching for forward primers
    
for i = 1:len2-minovl
    [al1, al2] = align(seq1, seq2(i:end));
    in = [find(al1 == 1) -find(al2 == 1)];
    if ~isempty(in)
        %found... something, return it (negative if reverse)
        out = in;
        outlen = len2-i+1;
        return
    end
end
else % chop from other end - for searching for rev primers
for i = len2:-1:minovl
    [al1, al2] = align(seq1, seq2(1:i));
    in = [find(al1 == 1) -find(al2 == 1)];
    if ~isempty(in)
        %found... something, return it (negative if reverse)
        out = in;
        outlen = len2-i+1;
        return
    end
end
end    