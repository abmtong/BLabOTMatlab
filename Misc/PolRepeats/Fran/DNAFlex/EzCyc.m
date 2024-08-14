function [out, outraw, hasrna] = EzCyc(infp, gff)
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
    hasrna = 0;
else
    gff = procRnaSeq(rnafp, gff);
    hasrna = 1;
end

%Load nucleosome .bed
nucmap = procNucMap(infp);

%Get nuc flex's
nucseq = getNucFlex(gff, nucmap);

%Plot a few ways:
%by Gene
o1 = plotNucFlex(nucseq);

%by RNAseq
if hasrna
    o2 = plotNucFlex_RNA(nucseq);
else
    o2 = [];
end

%by TSS
o3 = plotNucFlex_TSS(nucseq);
o4 = plotNucFlex_TSS(nucseq, 1:20);

%Set output
out = nucseq;

outraw = {o1 o2 o3 o4};








