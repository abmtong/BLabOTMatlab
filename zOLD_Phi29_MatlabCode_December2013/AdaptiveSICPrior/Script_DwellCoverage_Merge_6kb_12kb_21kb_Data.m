function Dwells = Script_DwellCoverage_Merge_6kb_12kb_21kb_Data(Dwells_6kb, Dwells_12kb, Dwells_21kb)
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
DNALength    = [6200 12500 21000]; %in bp
GenomeLength = 19300; %in bp
FillingBins  = 5:10:110; %in percent

Data{1} = Dwells_6kb;
Data{2} = Dwells_12kb;
Data{3} = Dwells_21kb;
Dwells.Duration      = [];
Dwells.Filling       = [];
Dwells.SizeStepAfter = [];

for i=1:3
    KeepInd = Data{i}.SizeStepAfter>MinStepSize & Data{i}.SizeStepAfter<MaxStepSize;
    Dwells.Duration       = [Dwells.Duration      Data{i}.Duration(KeepInd)];
    Dwells.SizeStepAfter  = [Dwells.SizeStepAfter Data{i}.SizeStepAfter(KeepInd)];
    Dwells.Filling        = [Dwells.Filling       (DNALength(i)-Data{i}.Location(KeepInd))./GenomeLength*100]; %in percent
end

figure; hist(Dwells.Filling,FillingBins);
xlabel('Capsid Filling (%)'); ylabel('# of Validated Dwells');

