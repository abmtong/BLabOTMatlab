function out = loadSeqs_andProcessV2(infp)
%Loads a fastq file from SRA (NIH Sequence Read Archive)
%And does the searching I want (check against mcherry sequence)

%This is a text file with 4 types of lines repeating, e.g.:
%{
@SRR3669857.1 FCD2BN5ACXX:2:1101:1247:1976# length=49
NGAACTGCTCGCTAGCCCAGCGCATACCCAGCATGGTTTTCAGCGTGTT
+SRR3669857.1 FCD2BN5ACXX:2:1101:1247:1976# length=49
?????????????????????????????????????????????????
@SRR3669857.2 FCD2BN5ACXX:2:1101:1479:1963# length=49
NGGATCAATTTTCGCATTTTTTGTAAGGAGGGGGGTCATCAAAATTTGC
+SRR3669857.2 FCD2BN5ACXX:2:1101:1479:1963# length=49
?????????????????????????????????????????????????
%}

%This is the ID ; sequence ; ID ; quality factor
%ID is the SRA ID followed by the Illumina metadata:
%@SRR3669857.1 FCD2BN5ACXX:2:1101:1247:1976# length=49
%@[SRA_ID].[Read] [Instrument]:[Lane]:[Number]:[X]:[Y]# length=[Read_Length]

%Let's just get the seqs. 49bp x 1e8 spots = 5gb, ok
% Maybe can store compressed? since its just ATGCN

if nargin < 1
    [f, p] = uigetfile('*.fastq');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

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
%And also save rcomp
rseq = seqrcomplement(seq);


fid = fopen(infp);

% len = 117736006; %This is how many reads there are, for prealloc reasons. NO longer necessary
nhitguess = round(1e6); %Guess of how many hits, for prealloc. Or just prealloc the largest 'small' mtx

%Save output
out1 = nan(2,nhitguess); %Save [n_line; seqpos]
ind1 = 0; %Marker
out2 = nan(2,nhitguess);
ind2 = 0;

%Index for lines + out
ind = 0; %Sequence number
lnno = 0; %Line number, in file
nreject = 0; %Number rejects
while ~feof(fid)
    %Get line
    ln = fgetl(fid);
    lnno = lnno + 1;
    %Only save lines ~ 2 mod 4 
    if mod(lnno, 4) == 2
        tmp = ln;
        ind = ind + 1;
        
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
end
fclose(fid);

%Trim
out1 = out1(:,1:ind1);
out2 = out2(:,1:ind2);

%Assemble output
out.out1 = out1;
out.out2 = out2;
out.n = ind;
out.nreject = nreject;
