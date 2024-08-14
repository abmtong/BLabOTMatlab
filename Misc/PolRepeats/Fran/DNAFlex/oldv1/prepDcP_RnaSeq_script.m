%prepDcP_RnaSeq_script


%One-time load
%Run this to load the genome + annotation as hg
hg = procGenome;

%Run just this afterwards
%Load NucMap
nm = procNucMap();

%Load RNA seq data
hgr = procRnaSeq([], hg);

%Get NucSeq
ns = getNucSeqs_RnaSeq(hgr, nm);

%Create fasta for DNAcycP
prepDcP_RnaSeq(ns);

%Then (if you want) rename DcPin.fasta and DcPin_TPM.mat
