function [NewDwells,i,k,DwellStatus]=StepFinding_DealWithStartOverlap(Data,NewDwells,OldDwells,OverlapInd,i,k)
% This is part of the code for StepFinding_CompareNewVersusOldDwells that
% was taken out for readability reasons.
%
% USE: [NewDwells,i,k,DwellStatus]=StepFinding_DealWithStartOverlap(Data,NewDwells,OldDwells,OverlapInd,i,k)
%
% Gheorghe Chistol, 16 March 2011

%Just make the partial overlap its own dwell. DwellCleanUp will deal
%with it if it's too small or too close to another dwell

StartOverlap = NewDwells.start(i); %overlap starts here
EndOverlap = OldDwells.end(OverlapInd(k)); %overlap ends here
data = Data.FilteredContour(StartOverlap:EndOverlap);
Npts = length(data);

%the overlap becomes an independent step
%shift everything by one dwell to the right
%disp('    DealWithStartOverlap: Overlap becomes an independent step');
NewDwells.start(i+1:end+1) = NewDwells.start(i:end);
NewDwells.end(i+1:end+1)   = NewDwells.end(i:end);
NewDwells.Npts(i+1:end+1)  = NewDwells.Npts(i:end);
NewDwells.mean(i+1:end+1)  = NewDwells.mean(i:end);
NewDwells.std(i+1:end+1)   = NewDwells.std(i:end);

%record the overlap as an independent dwell 
NewDwells.start(i) = StartOverlap;
NewDwells.end(i)   = EndOverlap;
NewDwells.Npts(i)  = Npts;
NewDwells.mean(i)  = mean(data); %calculated about 10-15 lines above
NewDwells.std(i)   = std(data);

%update the next new dwell accordingly
NewDwells.start(i+1) = NewDwells.end(i)+1; %the end will remain the same though
data = Data.FilteredContour(NewDwells.start(i+1):NewDwells.end(i+1));
NewDwells.Npts(i+1)  = length(data);
NewDwells.mean(i+1)  = mean(data);
NewDwells.std(i+1)   = std(data);

DwellStatus='split'; %the new dwell has been split
i=i+1; %increment counter, move over to the next one
k=k+1;