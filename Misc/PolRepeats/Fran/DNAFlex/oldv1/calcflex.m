function out = calcflex(seq, refid)
%Predicts the flexibility of a DNA sequence
% For each dinucleotide, assigns a flexibility score

%If we convert ACGT > 1234, the dinucleotide XY is ref(x,y):
% In addition to being alphabetical, it makes the ref matrix symmetric about the / diagonal
if nargin < 2
    refid = 1;
end

switch refid
    case 1
        %Unipro UGENE's values: https://doc.ugene.net/wiki/display/UM38/DNA+Flexibility
        %        A    C     G    T
        ref = [ 7.6 10.9   8.8 12.5; ... A
               14.6  7.02 11.1  8.8; ... C
                8.2  8.9   7.2 10.9 ; ...G
               25    8.2  14.6  7.6];   %T
    case 2
        %TRX values from TRX-LOGOS package: https://scfbm.biomedcentral.com/articles/10.1186/s13029-015-0040-8#Sec18
        % Is the 'percentage of time the backbone spends in the B-II conformation, higher GC tends to have higher values (so ~ stiffness), see doi:10.1093/nar/gkp962
        %        A  C  G  T
        ref = [05 04 09 00; ...A
               42 42 43 09; ...C
               22 25 42 04; ...G
               14 22 42 05];  %T
        ref = 100-ref; %Flip so higher = more flexible
end
%Want to try to get a more complex one 

%Convert to all caps
seq = upper(seq);

%Convert seq to numbers. Leave non-ACGT as NaN
seqnum = nan(1, length(seq));
seqnum( seq == 'A' ) = 1;
seqnum( seq == 'C' ) = 2;
seqnum( seq == 'G' ) = 3;
seqnum( seq == 'T' ) = 4;

out = zeros(1, length(seq)-1);
for i = 1:length(seq)-1
    if any(isnan(seqnum(i:i+1)))
        out(i) = nan;
    else
        out(i) = ref(  seqnum(i), seqnum(i+1) );
    end
end

%Don't forget to smooth this by some amount to determine 'flexibility'
%Smooth by one turn? Less? More?

