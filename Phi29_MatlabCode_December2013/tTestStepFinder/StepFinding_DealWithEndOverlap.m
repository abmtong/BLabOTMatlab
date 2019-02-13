function [NewDwells,i,k,DwellStatus]=StepFinding_DealWithEndOverlap(Data,NewDwells,OldDwells,OverlapInd,i,k)
% This is a portion of the StepFinding_CompareNewVersusOldDwells code that
% has been taken out for readability reasons.
%
% USE: [NewDwells,i,k,DwellStatus]=StepFinding_DealWithEndOverlap(PhageData,NewDwells,OldDwells,OverlapInd,i,k)
%
% Gheorghe Chistol, 16 March 2011


% large partial overlap at the end of the new dwell:
%   3. Overlap is significant and belongs to the Old Dwell
%   4. Overlap is significant and belongs to the New Dwell
%   5. Overlap is significant and is distinct from either Old or New Dwell

StartOverlap = OldDwells.start(OverlapInd(k));
EndOverlap   = NewDwells.end(i); %overlap ends here
data         = Data.FilteredContour(StartOverlap:EndOverlap);

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
NewDwells.mean(i)  = mean(data);
NewDwells.std(i)   = std(data);

DwellStatus='split'; %the new dwell has been split
i=i+1; %increment counter, move over to the next one
k=k+1; %not that this matters