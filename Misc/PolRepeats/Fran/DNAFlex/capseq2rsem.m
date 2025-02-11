function out = capseq2rsem(infp, gff)
%Converts raw bedGraph of 5'cap seq to TPM [like RSEM output of RNA-seq data]
% Going to make some assumptions...
%Input bedGraph is a list of 5' ends, so we need to find the gene these are in and... sum the expression vals?

%gff could be the entire seq+cyc struct, remove seq and cyc fields just in case
if isfield(gff, 'seq')
    gff = rmfield(gff, 'seq');
end
if isfield(gff, 'cyc')
    gff = rmfield(gff, 'cyc');
end

if isempty(infp)
    [f, p] = uigetfile('*.*');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

pad = 1; %Pad gene position width by this much?

%Read lines, like:
%{
chr2	171770187	171770188	1.2458
chr2	171770188	171773729	0
%}
%If the line has 0 in the 4th col, this is space, skip
%If the line has a value in 4th col, this is the transcription level of a RNA with that 5' end
% There is a plus and minus column: I assume this is strandedness -- this also negates the values, assume taking abs() is ok then
%  Should double-check by e.g. seeing if the distribution of the + and - values are similar. can also maybe group them in one file
%   (Yes, this is the case, the distribution of abs(vals) is similar in both files)

fid = fopen(infp);
raw = textscan(fid, '%s %d %d %f');
fclose(fid);

%Get the cols we want
chr = raw{1};
pos = raw{2};
tpm = raw{4};

%Remove 0s
ki = tpm ~= 0;
chr = chr(ki);
pos = pos(ki);
tpm = tpm(ki);

% newgff = [];

%Skip chrM
gff( strcmp( {gff.chr}, 'chrM' ) ) = [];
nchr = length(gff);
outraw = cell(1,nchr);
parfor i = 1:nchr
    tmpg = gff(i);
    ngene = length(tmpg.name);
    
    %Get pos/tpm values of these guys
    ki = strcmp(chr, tmpg.chr);
    tpos = pos(ki);
    ttpm = tpm(ki);
    tstr = sign(ttpm)>0; %Convert TPM sign to strand
    
    used = false(size(ttpm));
    
    outrawraw = zeros(1, ngene);
    for j = 1:ngene
        tmp = tmpg.gendat(j,:);
        
        %For each gene, get the data that is within the bounds + on the correct strand
        ki = tpos >= (tmp(1)-pad) & tpos <= (tmp(2)+pad) & (tstr == tmp(3));
        % in gff, gendat(i,3) is the strand, ==1 for plus, ==0 for minus
        
        %And let's just sum these to get the TPMs for this gene. Let's assume they are normalized properly
        outrawraw(j) = abs(sum(ttpm(ki)));
        
        %Set used flag, for debug
        used(ki) = true;
    end
    outraw{i} = outrawraw;
    fprintf('Assigned %0.2f%% of TPMs to %0.2f%% of genes in %s\n',...
                    100*(sum(used)/length(used)),...
                    100*(sum(logical(outrawraw))/ngene), ...
                    tmpg.chr);
%     newgff(i) = tmpg;
end

% out = newgff;
%Write to RSEM file, which is a tsv with columns:
colstr = {'gene_id'  'transcript_id(s)' 'length' 'effective_length' 'expected_count' 'TPM' 'FPKM'};
%I.... think we just want the gene_id field and TPM field, so fill the rest with 0s or whatever

outfn = 'out.rsem';

fid = fopen(outfn, 'w');
%Write columns
fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', colstr{:});

%Concatenate gene data
catdat = [outraw{:}]';
catnam = cellfun(@(x) x', {gff.name}, 'Un', 0);
catnam = [catnam{:}]';
len = length(catnam);

for i = 1:len
    %Write
    fprintf(fid, '%s\t0\t0\t0\t0\t%f\t0\n', catnam{i}, catdat(i));
end

fclose(fid);

%Create gene_id, which is gene-[geneID from gff]

% writetable(tbl, 'out.rsem', 'FileType', 'text', 'Delimiter', 'tab')

% Maybe just do fprintf instead...






