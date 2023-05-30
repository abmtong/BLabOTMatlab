function prepDcP_rand(gen, maxn, bpperchunk)
%Outputs random sequences given a genome
% Let's just get random stretches of 1e4bp each?

%An edit of prepDcP, mi

%Process gen: remove chrM (mitochondrial DNA)
ki = find(strcmp({gen.chr},'chrM'));
if ki
    gen(ki) = [];
end

%Maximum number of 'chunks', for limiting runtime
if nargin < 2
    maxn = 100;
end

%Maximum number of NPSes per 'chunk' fed to DNAcycP. Too high and you can run out of RAM? And gives you incremental outputs
if nargin < 3
    bpperchunk = 3e6; %Tuned for Human, try ~0.01* chr size
end

%Concatenate sequences
seq = [gen.seq];
len = length(seq);
%Get the index where the bdys are, so we don't take intra-chromosome data
bdys = cumsum ( arrayfun(@(x)length(x.seq), gen ) );

stT = tic;

%Write to FASTA
fid = fopen('DcPin.fasta','w');
nwrit = 0;
while nwrit < maxn
    %Get a random sequence of length bpperchunk
    st0 = randi(len - bpperchunk);
    %Check that the sequence doesn't include the intra-chr bdy
    % Might not be necessary, since ends are probably filled with N's and will get rejected by the next check
    if any( st0 < bdys & st0 + bpperchunk -1 > bdys )
        fprintf('Sequence starting at %d rejected because of chr boundary\n', st0)
        continue
    end
    
    %Get the sequence
    tmp = upper( seq( st0:st0+bpperchunk-1 ) );
    %Check that sequence is all ATGC
    if ~all( tmp == 'A' | tmp == 'G' | tmp == 'C' | tmp == 'T' )
        fprintf('Sequence starting at %d rejected because of non-ATGC\n', st0)
        continue
    end
    
    %Sequence is okay, so increment counter and write to file
    nwrit = nwrit + 1;
    %Write >Name line
    fprintf(fid, '>Genes_%s%d\n', 'b', nwrit);
    %Write sequence
    fprintf(fid, '%s\n', tmp);
end
fclose(fid);
fprintf('%s finished in %0.2fs\n', mfilename(), toc(stT))

%Then run DNAcycP on this fasta (outside Matlab)
% The goal is to find the mean, sd of the human genome cyc-ity
