function [out, outraw] = cddColorBits(cdddat, pdbstartres)
%Calculates relative entropy of each position in an MSA
% Calculation/idea taken from Conserved Domain Database (CDD), they call it 'color bits'

%CHECK that the pdb starts at residue 1 : the CCD numbering sets the first residue as 1, else you need to shift out(:,1)
% If it's not, pass it as pdbstartres

%Color bit calc is:
%Bits = sum ( f(i) * log2(f(i)/q(i)) ) over i (residue types) at a given position
% f(i) = observed freq, q(i) = ref freq
% So if gly = 1, then f(1) = n_gly / n_seqs ; q(i) = reference probability
%  Im assuming that f(i) = 0 then the '0 times -inf' becomes zero

if nargin < 2
    pdbstartres = 1; %Assume pdb starts at residue 1
end

nseq = length(cdddat);
len = length(cdddat(1).seq);
outraw = nan(1,len);
%Combine the residues to a n_seq x len mtx
rsdmtx = reshape( [cdddat.seq] , len, [])';

%AA freq background for calculating bits
% Sourced from Table 2 of this paper https://academic.oup.com/bioinformatics/article/21/7/902/268768#394064499
% CCD site says they calc bits with the 'table accompanying BLOSUM62' but I can't (officially) find this
% The final values are slightly off compared to what the CCD website shows, but EH (maybe site rounds this table to nearest integer?)
blores = 'ARNDCQEGHILKMFPSTWYV'; %AA order
%       A   R   N   D   C   Q   E   G   H   I   L   K   M   F   P   S   T   W   Y   V
blo = [7.4 5.2 4.5 5.3 2.5 3.4 5.4 7.4 2.6 6.8 9.9 5.8 2.5 4.7 3.9 5.7 5.1 1.3 3.2 7.3]; %Percent
blo = blo/sum(blo); %Normalize

for i = 1:len
    %Check whether this column is aligned (caps letter) or not (lower or dash)
    %A-Z is char(65-90), so just check for that...
    if rsdmtx(1,i) >= 45 && rsdmtx(1,i) <= 90
        %Get this column's letters
        col = rsdmtx(:,i);
        
        %Calculate bits (see header for info on calc.)
        tmpbit = 0;
        %For each residue type
        for j = 1:20
            %Get % of residues of this type at this site
            n = sum( col == blores(j) ) / nseq;
            %Or does this expect an odds ratio?
%             n = sum( col == blores(j) );
%             n = n / (nseq-n);
            %Only add if there is this residue in the mix, else its 0 * log(0) which is NaN
            if n > 0
                tmpbit = tmpbit + n * log2( n / blo(j) );
%                 tmpbit = tmpbit + n * (log2(n) - blo(j) );
            end
        end
        %And save bits
        outraw(i) = tmpbit;
    end
end

%Create the [residue number, bits] matrix for eg passing to setBs:

%Crop outraw to only the residues (i.e., no dashes)
ki = ~(cdddat(1).seq == '-');
outdir = outraw(ki);
out = [(0:length(outdir)-1)'+cdddat(1).startres+pdbstartres-1    outdir(:)];

%Debug plot: Graph of bits + sequence with color bits (like the CDD website)
debug = 0;
if debug
    minbit = 2;
    %Plot bits
    figure
    plot(out(:,1),out(:,2))
    
    %And sequence, colored
    outres = cdddat(1).seq(ki);
    for i = 1:length(outres)
        if isnan(out(i,2))
            col = 'k';
        elseif out(i,2) > minbit
            col = 'r';
        else
            col = 'b';
        end
        text(out(i,1), minbit, outres(i), 'Color', col);
    end
    
    
end






