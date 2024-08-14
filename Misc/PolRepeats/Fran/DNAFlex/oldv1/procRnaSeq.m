function out = procRnaSeq(infp, gff)
%Get processed RNA-seq data from NucMap (processed by RSEM)
%This function loads it, to compare to gene placements

%File format is 
%{
gene_id	transcript_id(s)	length	effective_length	expected_count	TPM	FPKM
gene-A1BG	rna-NM_130786.4	3382.00	3332.00	3.20	0.03	0.02
gene-A1BG-AS1	rna-NR_015380.2	2130.00	2080.00	8.00	0.11	0.07
gene-A1CF	rna-NM_001198818.2,rna-NM_001198819.2,rna-NM_001198820.2,rna-NM_001370130.1,rna-NM_001370131.1,rna-NM_014576.4,rna-NM_138932.3,rna-NM_138933.3,rna-XM_005269718.2,rna-XM_011539729.3,rna-XM_011539730.2,rna-XM_024447966.1	9088.00	9038.00	3.00	0.01	0.01

So read first line, then load as %s %s %f %f %f %f %f
%}


if nargin < 1 || isempty(infp)
    [f p] = uigetfile('*.rsem', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        out = cellfun(@(x) procRnaSeq(fullfile(p,x), gff), f, 'Un', 0);
        return
    else
        infp = fullfile(p,f);
    end
end

%Load file
fid = fopen(infp);
%Skip first line, which is column names
fgetl(fid);
tmp = textscan(fid, '%s %s %f %f %f %f %f', 'Delimiter', {'\t' '\n'});
fclose(fid);

%Get the two columns we care about
gennam = tmp{1};
gentpm = tmp{6};
len = length(gennam);
nch = length(gff);

%First, create field to store data
for i = 1:nch
    gff(i).tpm = nan(size(gff(i).name));
end

%Annotate gff with TPM
for i = 1:len
    %Find gennam that matches name
    
    %Maybe shouldnt have the data struct be like this, so we can do it in one loop, but EH
    tffound = 0;
    for j = 1:nch
        ind = find(strcmp(gff(j).name,gennam{i}));
        if ind
            gff(j).tpm(ind) = gentpm(i);
            tffound = 1;
        end
    end
%     if ~tffound && gentpm(i) > 0
%         warning('Didnt find gene %s', gennam{i})
%         %This will be hit a lot, mostly it should be for pseudogenes? but some genes just not in the gff?
%     end
end


out = gff;