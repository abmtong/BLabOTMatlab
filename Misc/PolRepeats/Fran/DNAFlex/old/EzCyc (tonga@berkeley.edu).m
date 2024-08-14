function out = EzCyc(infp, gff)
%Does Nuc DNA cyclizibility analysis on nucleosome positioning data

%inputs: infp: path to nuc position .bed (named [name].nucleosome.[]Peak.bed)
%              For paired RNA-seq data, this is fetched by filename: it should be named [name].rna_seq.rsem
%        gff: Genome sequence + annotation + flexibility
%              See @procGenome for sequence/annotation and @cycGenome_p1/2 for flexibility
narginchk(2,2)

if isempty(infp)
    [f, p] = uigetfile('*.bed', 'Select the Nucleosome peak .bed');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

%Check for RNA seq data and add to gff if exists
[p, f , ~] = fileparts(infp);
rnaf = f( 1: find(f == '.', 2, 'last')-1 ); %Strip two .'s
rnaf= [rnaf '.rna_seq.rsem'];
rnafp = fullfile(p,rnaf);
if ~exist(rnafp, 'file')
    warning('No linked RNA-seq data found.')
    %Maybe add a field of NaNs to gff...
else
    gff = procRnaSeq(rnafp, gff);
end

%Load nucleosome .bed
nucmap = procNucMap(infp);

%Get nuc flex's
nucflx = getNucFlex(gff, nucmap);

%Plot a few ways:
%1: Standard W-chart

%2: By RNPS

%Set output
out = nucflx;
%Create files
% foo = prepDcPv2(nucseq, maxn, seqperchunk);
%[Run them in DNAcycP or other prediction algorithm]

%[Import them with DNAcycp2]

%Analyze












