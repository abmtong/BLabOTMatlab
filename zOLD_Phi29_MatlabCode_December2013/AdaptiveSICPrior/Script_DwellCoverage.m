function Script_DwellCoverage(Dwells)
% This is actually a function
% It generates a figure to show how many dwells exist for a certain capsid filling
% Dwells.Duration
% Dwells.Location
% Dwells.SizeStepBefore
% Dwells.SizeStepAfter
% 
% Gheorghe Chistol, 31 Oct 2012

MinStepSize  = 8;  %in bp
MaxStepSize  = 11; %in bp
%DNALength    = 6200; %in bp
%DNALength    = 12500; %in bp
DNALength    = 21000; %in bp
GenomeLength = 19300; %in bp
FillingBins  = 5:10:110; %in percent

KeepInd = Dwells.SizeStepAfter>MinStepSize & Dwells.SizeStepAfter<MaxStepSize;

Dwells.Duration       = Dwells.Duration(KeepInd);
Dwells.Location       = Dwells.Location(KeepInd);
Dwells.SizeStepAfter  = Dwells.SizeStepAfter(KeepInd);
Dwells.SizeStepBefore = Dwells.SizeStepBefore(KeepInd);
Dwells.Filling        = (DNALength-Dwells.Location)./GenomeLength*100; %in percent

figure;
hist(Dwells.Filling,FillingBins);
xlabel('Capsid Filling (%)');
ylabel('Count');

