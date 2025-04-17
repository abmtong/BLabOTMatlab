%{
Readme for submission to Molecular Cell for manuscript:
    FACT weakens the nucleosomal barrier to transcription and preserves its integrity by promoting the formation of a hexasome-like intermediate

Code for converting raw instrument data into force and extension are found in \RawDataProcessing\AProcessDataV2.m

Code for analyzing optical tweezers transcription through a nucleosome are found in \Misc\PolRepeats\Fran\.
    The analysis pipeline is procFranp*.m
    Molecular ruler alignment was done with code found in \Misc\PolRepeats\rulerAlignV2.m

Code for analyzing nucleosome pulling data is found in \Misc\NucUnwrapping\
    Identification of the high-force transition and low-force transition is done by visual inspection
    Analysis for unwrapping a nucleosome after transcription is done by visual inspection with TxPullGUI.m

Code for analyzing NPS data from NucMap are found in \Misc\PolRepeats\Fran\DNAFlex\
    Human genome data and annotation are loaded with procGenomeV2.m
    DNAcycP input files are prepared using cycGenome_p1.m and, after running DNAcycP, are loaded into Matlab with cycGenome_p2.m
    After predicting the cyclizibility of the genome using DNAcycP, analysis is done with EzCyc_batch.m
%}