function out = gcStats(chrseq)

nchr = length(chrseq);
outrawN = zeros(nchr,3);
outrawGC = zeros(nchr,3);
for i = nchr:-1:1
    %Sequence
    seq = upper(chrseq(i).seq);
    
    %Location of genes: 1 if it is in a + gene, -1 if in a rev gene
    ngene = size( chrseq(i).gendat, 1);
    genmap = zeros(size(seq));
    for j = 1:ngene
        genmap( chrseq(i).gendat(j,1) : chrseq(i).gendat(j,2) ) = chrseq(i).gendat(j,3)*2-1;
    end
    
    %Last gene might somehow be outside the edge of the sequence? so crop
    genmap = genmap(1:length(seq));
    
    outrawN(i,:) = [sum(genmap == -1) sum(genmap == 0) sum(genmap == 1)];
    
    tfgc = seq == 'G' | seq == 'C';
    
    outrawGC = [sum(tfgc(genmap == -1)) sum(tfgc(genmap == 0)) sum(tfgc(genmap == 1))];
    
end

outraw = [outrawGC outrawN];
out = sum(outraw, 1);