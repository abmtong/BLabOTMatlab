function out = loadSeqs_andProcess(infp)
%Loads a fastq file from SRA (NIH Sequence Read Archive)
%And does the searching I want

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


%mCherry minus 5aa on each side
seq1 = ['EEDNMAIIKEFMRFKVHMEGSVNGHEFEIEGEGEGRPYEGTQTAKLKVTKGGPLPFAWDILSPQFMYGSKAYVKH'...
'PADIPDYLKLSFPEGFKWERVMNFEDGGVVTVTQDSSLQDGEFIYKVKLRGTNFPSDGPVMQKKTMGWEASSERMYPEDG'...
'ALKGEIKQRLKLKDGGHYDAEVKTTYKAKKPVQLPGAYNVNIKLDITSHNEDYTIVEQYERAEGRHSTGGM'];

%RanGAP main exon
seq2 = ['QDVVDALNKQTTVHYLNLDGNTLGVEAAKAIGEGLKRHPEFRKALWKNMFTGRLISEIPEALKHLGAALIVAGAKLTVLD'...
'LSDNALGPNGMRGLEELLRSPVCYSLQELLLCNCGLGPEGGSMLSRALIDLHANANKAGFPLQLRVFIGSRNRLEDAGAT'...
'EMATAFQTLKTFEEIVLEQNSIYIEGVEALAESFKHNPHLRVLNMNDNTLKSEGAEKIAEALPFLP'];

fid = fopen(infp);

% %Might be faster if we just read specific locs? Reads are always(?) 49bp and start at
% %0x36, 106, 1D6, 2A6, 376 ... , 0x36 + 0xD0 per , read 49bp
% %Store these details here
% x0 = 3*16+6;
% wid = 49;
% dx = 14*6;
% %Oh, the width changes as read number increases. so dx depends on len
% % EH just fgetl it 

len = 117736006; %This is how many reads there are
% out = cell(1,
% 
% while true
% %Seek
% 
% end

%Save output
out1 = false(1,len);
out2 = false(1,len);
% Lets say -1 = rejected, 0 = no find, 1/2/3 = found in orf 1/2/3 

%Index for lines + out
ind = 1;
lnno = 0;
nreject = 0;
while ~feof(fid)
    %Get line
    ln = fgetl(fid);
    lnno = lnno + 1;
    %Only save lines ~ 2 mod 4 
    if mod(lnno, 4) == 2
        tmp = ln;
        ind = ind + 1;
        %Reads are 49bp long. Lets take 45bp regions, so its always 15aa
        % Looking at reads, a bunch of bad reads at pos 1, then a bit at pos 2, 44, 48
        % So lets take 3-47, 4-48, 5-49 ?
        
        %Crop to 3-49
        tmp = tmp(3:49);
        
        %Reject if there's Ns 
        if any(tmp  == 'N')
            nreject = nreject + 1;
            continue
        end
        
        %% OOPS forgot that it could be either direction, so need to check revcomp too...
        
        %Try ORF 1
        tseq = nt2aa(tmp(1:45));
        %First check for stop codon, skip if it has stop
        if ~any(tseq == '*')
            if strfind(seq1, tseq)
                out1(ind) = true;
            end
            if strfind(seq2, tseq)
                out2(ind) = true;
            end
        end
        
        %Try ORF 2
        tseq = nt2aa(tmp(2:46));
        if ~any(tseq == '*')
            if strfind(seq1, tseq)
                out1(ind) = true;
            end
            if strfind(seq2, tseq)
                out2(ind) = true;
            end
        end
        
        %Try ORF 3
        tseq = nt2aa(tmp(3:47));
        if ~any(tseq == '*')
            if strfind(seq1, tseq)
                out1(ind) = true;
            end
            if strfind(seq2, tseq)
                out2(ind) = true;
            end
        end
        
    end
end

%Assemble output
out.out1 = out1;
out.out2 = out2;
out.nreject = nreject;
