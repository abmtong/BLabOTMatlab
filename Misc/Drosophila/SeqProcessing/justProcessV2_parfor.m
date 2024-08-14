function out = justProcessV2_parfor(inseqs, seq)
%inseqs is nseqs x seqlen char array
% seq is search sequence

%The chance should be miniscule, but make sure the hits aren't also in Drosophila

if nargin < 2
    %mCherry seq https://www.ncbi.nlm.nih.gov/nuccore/55420612
    % Lets assume the mcherry they used is the same seq as this...
    seq = [' atggtgagca agggcgagga ggataacatg gccatcatca aggagttcat gcgcttcaag'...
        ' gtgcacatgg agggctccgt gaacggccac gagttcgaga tcgagggcga gggcgagggc'...
        ' cgcccctacg agggcaccca gaccgccaag ctgaaggtga ccaagggtgg ccccctgccc'...
        ' ttcgcctggg acatcctgtc ccctcagttc atgtacggct ccaaggccta cgtgaagcac'...
        ' cccgccgaca tccccgacta cttgaagctg tccttccccg agggcttcaa gtgggagcgc'...
        ' gtgatgaact tcgaggacgg cggcgtggtg accgtgaccc aggactcctc cctgcaggac'...
        ' ggcgagttca tctacaaggt gaagctgcgc ggcaccaact tcccctccga cggccccgta'...
        ' atgcagaaga agaccatggg ctgggaggcc tcctccgagc ggatgtaccc cgaggacggc'...
        ' gccctgaagg gcgagatcaa gcagaggctg aagctgaagg acggcggcca ctacgacgct'...
        ' gaggtcaaga ccacctacaa ggccaagaag cccgtgcagc tgcccggcgc ctacaacgtc'...
        ' aacatcaagt tggacatcac ctcccacaac gaggactaca ccatcgtgga acagtacgaa'...
        'cgcgccgagg gccgccactc caccggcggc atggacgagc tgtacaagta a'];
    %This is 711bp long, let's compare against other 711bp sections in Dro. Maybe in RanGap
    
    %Remove spaces, upper()
    seq(seq == ' ') = [];
    seq = upper(seq);
end

%And also save rcomp
rseq = seqrcomplement(seq);

len = size(inseqs, 1); %This is how many reads there are
% nhitguess = round(1e6); %Guess of how many hits, for prealloc. Or just prealloc the largest 'small' mtx

%Save output
out1 = zeros(1,len, 'uint32'); %Save overlap position
out2 = zeros(1,len, 'uint32');

%Save as int for speed/memory? Make sure len < intmax u32 (4e9)

%Index for lines + out
% lnno = 0; %Line number, in file
nreject = 0; %Number rejects
parfor ind = 1:len
        tmp = inseqs(ind,:);
        
        %Reject if there's Ns. Maybe let these be wildcards? eh
        if any(tmp  == 'N')
            nreject = nreject + 1;
            continue
        end

        %Check against seq
        sf1 = strfind(seq, tmp);
        if sf1
%             ind1 = ind1 + 1;
            out1(:,ind) = sf1(1);
        end
        %Check against rseq
        sf2 = strfind(rseq, tmp);
        if sf2
%             ind2 = ind2 + 1;
            out2(:,ind) = sf2(1);
        end
end

%Trim to nonzero
ifind1 = find(out1);
ifind2 = find(out2);
out1 = out1(ifind1);
out2 = out2(ifind2);

%Assemble output
out.out1 = [ifind1(:) out1(:)];
out.out2 = [ifind2(:) out2(:)];
out.n = len;
out.nreject = nreject;
