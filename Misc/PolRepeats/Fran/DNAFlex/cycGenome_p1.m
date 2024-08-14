function cycGenome_p1(inst)
%Maybe it's worth just DNAcycP'ing the ENTIRE genome

maxbp = 3e6;

outf = 'out15.fasta';
fid = fopen(outf, 'w');

nfile = 0;
for i = 1:length(inst)
    %Grab data
    chr = inst(i).chr;
    seq = inst(i).seq;
    nbp = length(seq);
    
    %DNAcycP only wants ATGC, so make others N
    seq = upper(seq);
    ok = seq == 'A' | seq == 'T' |seq == 'G' |seq == 'C'|seq == 'N';
    seq(~ok) = 'N';
    nbad = sum(~ok);
    fprintf('Nulled out %d/%d (%0.1f%%) nuc in %s\n', nbad, nbp, nbad/nbp*100, chr)
    
    
    %Chop into chunks
    nchk = ceil( nbp / maxbp );
    
    
    %Let's send maxbp in each, but for the second-on lets back-pad by 50bp
    st = 1;
    for j = 1:nchk
        
        %Get end position
        if j == nchk
            en = nbp;
        else
            en = st + maxbp;
        end
        
        %Move start position if early
        if j > 1
            st = st - 100;
        end
        
        tmp = seq(st:en);
        
        %Write first line, genome ID
        fprintf(fid, '>%s_%d\n', chr, st); %Mark with end, so we'll always know for sure the start pos
        fprintf(fid, '%s\n', tmp);
        nfile = nfile + 1;
%         fprintf('>%s_%d\n', chr, st); %Mark with end, so we'll always know for sure the start pos
        st = en; 
    end
end
fclose(fid);

fprintf('Wrote a fasta containing %d sub-sequences.\n', nfile)