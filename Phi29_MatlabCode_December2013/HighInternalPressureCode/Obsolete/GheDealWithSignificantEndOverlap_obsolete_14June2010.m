function [NewDwells, i, k, status ] = GheDealWithSignificantEndOverlap(phageData, NewDwells, OldDwells, OverlapInd, BinThr, i, k, status)
%This is a script which is part of the GheCompareNewVersusOldDwells.m
%function, but I had to take it out separately for readability reasons.
% Revised June 10
%
%Gheorghe Chistol, May 31, 2010

%large partial overlap at the end of the new dwell:
%   3. Overlap is significant and belongs to the Old Dwell
%   4. Overlap is significant and belongs to the New Dwell
%   5. Overlap is significant and is distinct from either Old or New Dwell

StartOverlap = OldDwells.start(OverlapInd(k));
EndOverlap   = NewDwells.end(i); %overlap ends here
data         = phageData.contour(StartOverlap:EndOverlap);
Npts         = length(data);
%Calculate the NptsAbove for the overlap with respect to the Old Dwell
%Binomial Check if the overlap belongs to the Old Dwell
NptsAboveOld = length(find(data>OldDwells.mean(OverlapInd(k))));
VerdictOld   = GheBinomialVerdict(NptsAboveOld, Npts, BinThr); 

%Calculate the NptsAbove for the overlap with respect to the New Dwell
%Binomial Check if the overlap belongs to the New Dwell
NptsAboveNew = length(find(data>NewDwells.mean(i)));
VerdictNew   = GheBinomialVerdict(NptsAboveNew, Npts, BinThr); 

if strcmp(VerdictNew,'diff') && strcmp(VerdictOld,'diff')
    %overlap is distinct from either old or new dwells
    %the overlap becomes an independent step
    disp('    GheDealWithSignificantEndOverlap: Overlap becomes an independent step');
    %shift everything by one dwell to the right    
    NewDwells.start(i+1:end+1) = NewDwells.start(i:end);
    NewDwells.end(i+1:end+1)   = NewDwells.end(i:end);
    NewDwells.Npts(i+1:end+1)  = NewDwells.Npts(i:end);
    NewDwells.mean(i+1:end+1)  = NewDwells.mean(i:end);
    NewDwells.std(i+1:end+1)   = NewDwells.std(i:end);

    %record the overlap as an independent dwell 
    NewDwells.start(i) = StartOverlap;
    NewDwells.end(i)   = EndOverlap;
    data               = phageData.contour(StartOverlap:EndOverlap);
    NewDwells.Npts(i)  = length(data);
    NewDwells.mean(i)  = mean(data); %calculated about 10-15 lines above
    NewDwells.std(i)   = std(data);

    %update the next new dwell accordingly
    NewDwells.start(i+1) = NewDwells.end(i)+1;
    data = phageData.contour(NewDwells.start(i+1):NewDwells.end(i+1));
    NewDwells.Npts(i+1)  = length(data);
    NewDwells.mean(i+1)  = mean(data);
    NewDwells.std(i+1)   = std(data);

    status='split'; %the new dwell has been split
    i=i+1; %increment counter, move over to the next one
    k=k+1; %not that this matters
    
elseif strcmp(VerdictOld,'same')
    %overlap belongs to the old dwell
    disp('    GheDealWithSignificantEndOverlap: Overlap belongs to the Old Dwell');
    %update current dwell accordingly    
    NewDwells.end(i) = StartOverlap-1;
    data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
    NewDwells.Npts(i)  = length(data);
    NewDwells.mean(i)  = mean(data); 
    NewDwells.std(i)   = std(data);

    %update the next new dwell to reflect the new changes
    NewDwells.start(i+1)   = NewDwells.end(i)+1;
    data = phageData.contour(NewDwells.start(i+1):NewDwells.end(i+1));
    NewDwells.Npts(i+1)  = length(data);
    NewDwells.mean(i+1)  = mean(data);
    NewDwells.std(i+1)   = std(data);

    status='split'; %the new dwell has been split
    i=i+1; %increment counter, move over to the next one
    k=k+1;
else
    disp('    GheDealWithSignificantEndOverlap: Overlap belongs to the New Dwell, keeping it.');
    %overlap belongs to the new dwell
    i=i+1; %move on to the next one
    k=k+1; %increment the counter for the overlapping OldDwells
end