function out = loadSeqs(infp)
%Loads a fastq file from SRA (NIH Sequence Read Archive)

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

fid = fopen(infp);

% %Would be faster if we just read specific locs? Reads are always(?) 49bp and start at
% %0x36, 106, 1D6, 2A6, 376 ... , 0x36 + 0xD0 per , read 49bp
% %Store these details here
% x0 = 3*16+6;
% wid = 49;
% dx = 14*6;
% %Oh, the width changes as read number increases. so dx depends on len
% % EH just fgetl it 

len = 117736006; %This is how many reads there are, or at least an upper limit for prealloc
out = cell(1,len);

%Index for lines + out
ind = 1;
lnno = 0;
while ~feof(fid)
    %Get line
    ln = fgetl(fid);
    lnno = lnno + 1;
    %Only save lines ~ 2 mod 4 
    if mod(lnno, 4) == 2
        out{ind} = char(ln);
        ind = ind + 1;
    end
end
fclose(fid);

%Remove unused cells
out(ind:end) = [];


