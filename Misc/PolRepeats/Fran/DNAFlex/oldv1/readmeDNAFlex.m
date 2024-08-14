%about DNAFlex
%{
Is the nucleosome positioning sequence asymmetric in stiffness?

Usage:
%Load genome .fna and RefSeq annotation .gff, in this case for hg38
hg = procGenome();

%Load NucMap from NucMap database, here nuc positions from DANPOS analysis
nm = procNucMap(); 

%Load RNA Seq data from NucMap database, here TPM values from RSEM analysis
rs = procRnaSeq([], hg);

%Get DNA sequences of the NPSes and collect metadata on the region they come from (gene direction, TPM)
ns = getNucSeqs_RnaSeq(rs, nm);

%Write to a .fasta to load into DNAcycP, and save corresponding TPM data in .mat
prepDcP_RnaSeq(ns);

%Run DNAcycP on the .fasta

%Load the output .txts from DNAcycP into Matlab
cyc = prepDcPp2();

%Load the TPM .mat made by prepDcP_RnaSeq, it's called tpmdat
tpmdat = load(--, 'tpmdat');

%Plot based on TPM
plotDcP_RNAseq(cyc, tpmdat)


%}