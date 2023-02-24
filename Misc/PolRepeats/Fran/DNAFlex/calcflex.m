function out = calcflex(seq)

%Calculates with Unipro UGENE's values:
%For each dinucleotide, assigns a flexibility
%If we convert ACGT > 1234, the dinucleotide XY is ref(x,y):
ref = [ 7.6 10.9 8.8 12.5; 14.6 7.02 11.1 8.8; 8.2 8.9 7.2 10.9 ; 25 8.2 14.6 7.6];

%Want to try to get a more complex one up and running (e.g. one that takes into account tetra's)

%Conver to all caps
seq = upper(seq);

%Convert seq to numbers
seqnum = zeros(1, length(seq));
seqnum( seq == 'A' ) = 1;
seqnum( seq == 'C' ) = 2;
seqnum( seq == 'G' ) = 3;
seqnum( seq == 'T' ) = 4;

out = zeros(1, length(seq)-1);
for i = 1:length(seq)-1
    out(i) = ref(  seqnum(i), seqnum(i+1) );
end

%Don't forget to smooth this by some amount to determine 'flexibility'
%Smooth by one turn? Less? More?

