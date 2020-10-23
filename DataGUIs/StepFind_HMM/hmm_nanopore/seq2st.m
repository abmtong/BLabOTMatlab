function [out, outi] = seq2st(seq, mu)
%Converts a nucleotide sequence ATGC.... to the corresponding state sequence

if nargin < 2
    mu = 1:256;
end

%Convert input sequence to indicies
if ischar(seq)
    %Convert ATGC to 1234 by prepending 'ATGC', call unique to discretize, then remove 'ATGC'
    seqi = ['ATGC' seq];
    [~, ia, ic] = unique(seqi);
    seq = ia(ic(5:end))';
end

len = length(seq)-3;

%For each nucleotide 4-mer, get the mu index and then output the state values
outi = zeros(1,len);
for i = 1:len
    outi(i) = cdn2num(seq(i:i+3));
end
out = mu(outi);