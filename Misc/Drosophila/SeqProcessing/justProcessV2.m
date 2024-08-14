function out = justProcessV2(inseqs, seq)
%inseqs is nseqs x seqlen char array
% seq is search sequence

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
nhitguess = round(1e6); %Guess of how many hits, for prealloc. Or just prealloc the largest 'small' mtx

%Save output
out1 = nan(2,nhitguess); %Save [n_line; seqpos]
ind1 = 0; %Marker
out2 = nan(2,nhitguess);
ind2 = 0;

%Index for lines + out
lnno = 0; %Line number, in file
nreject = 0; %Number rejects
for ind = 1:len

        tmp = inseqs(ind,:);
        
        %Reject if there's Ns. Maybe let these be wildcards? eh
        if any(tmp  == 'N')
            nreject = nreject + 1;
            continue
        end

        %Check against seq
        sf1 = strfind(seq, tmp);
        if sf1
            ind1 = ind1 + 1;
            out1(:,ind1) = [ind, sf1(1)];
        end
        %Check against rseq
        sf2 = strfind(rseq, tmp);
        if sf2
            ind2 = ind2 + 1;
            out2(:,ind2) = [ind, sf2(1)];
        end
end

%Trim
out1 = out1(:,1:ind1);
out2 = out2(:,1:ind2);

%Assemble output
out.out1 = out1;
out.out2 = out2;
out.n = len;
out.nreject = nreject;
