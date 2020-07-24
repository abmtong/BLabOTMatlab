function [NewDwells,i,k,DwellStatus]=StepFinding_DealWithMiddleOverlap(Data,NewDwells,OldDwells,OverlapInd,i,k)
% This is a portion of the StepFinding_CompareNewVersusOldDwells code that
% has been taken out for readability reasons.
%
% USE: [NewDwells,i,k,DwellStatus]=StepFinding_DealWithMiddleOverlap(PhageData,NewDwells,OldDwells,OverlapInd,i,k)
%
% Gheorghe Chistol, 16 March 2011


StartOverlap = OldDwells.start(OverlapInd(k));
EndOverlap = OldDwells.end(OverlapInd(k));
data = Data.FilteredContour(StartOverlap:EndOverlap);
%% Go ahead and split the overlap as a separate Dwell. 
% GheCleanUpDwells will deal with it later.
% Shift everything by one dwell to the right    
NewDwells.start(i+1:end+1) = NewDwells.start(i:end);
NewDwells.end(i+1:end+1)   = NewDwells.end(i:end);
NewDwells.Npts(i+1:end+1)  = NewDwells.Npts(i:end);
NewDwells.mean(i+1:end+1)  = NewDwells.mean(i:end);
NewDwells.std(i+1:end+1)   = NewDwells.std(i:end);

%record the overlap as an independent dwell 
NewDwells.start(i) = StartOverlap;
NewDwells.end(i)   = EndOverlap;
NewDwells.Npts(i)  = length(data);
NewDwells.mean(i)  = mean(data); %calculated about 10-15 lines above
NewDwells.std(i)   = std(data);

%update the beginning of the next dwell and everything else
NewDwells.start(i+1) = NewDwells.end(i)+1; %the end remains unchanged
data = Data.FilteredContour(NewDwells.start(i+1):NewDwells.end(i+1));
NewDwells.Npts(i+1)  = length(data);
NewDwells.mean(i+1)  = mean(data);
NewDwells.std(i+1)   = std(data);

DwellStatus='split'; %the new dwell has been split
i=i+1; %increment counter, move over to the next one
k=k+1; %not that this matters