function [NewDwells, i, k, status ] = GheDealWithSignificantStartOverlap(phageData, NewDwells, OldDwells, OverlapInd, BinThr, i, k, status)
% Revised 10 June, 2010
% Revised 14 June, 2010
%
% Gheorghe Chistol, 31 May, 2010
%
%large partial overlap at the beginning of the new dwell:
%1. Overlap is significant and belongs to the Old Dwell
%2. Overlap is significant and belongs to the New Dwell
%3. Overlap is significant and is distinct from either Old or New Dwell

StartOverlap = NewDwells.start(i); %overlap starts here
EndOverlap = OldDwells.end(OverlapInd(k)); %overlap ends here
data = phageData.contour(StartOverlap:EndOverlap);
Npts = length(data);
%Calculate the NptsAbove for the overlap with respect to the Old Dwell
%Binomial Check if the overlap belongs to the Old Dwell
NptsAboveOld = length(find(data>OldDwells.mean(OverlapInd(k))));
VerdictOld = GheBinomialVerdict(NptsAboveOld, Npts, BinThr); 

%Calculate the NptsAbove for the overlap with respect to the New Dwell
%Binomial Check if the overlap belongs to the New Dwell
NptsAboveNew = length(find(data>NewDwells.mean(i)));
VerdictNew = GheBinomialVerdict(NptsAboveNew, Npts, BinThr); 

% if strcmp(VerdictNew,'diff') && strcmp(VerdictOld,'diff')
    %overlap is distinct from either old or new dwells
    %the overlap becomes an independent step
    %shift everything by one dwell to the right
    %disp('    GheDealWithSignificantStartOverlap: Overlap becomes an independent step');
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
    data = phageData.contour(NewDwells.start(i+1):NewDwells.end(i+1));
    NewDwells.Npts(i+1)  = length(data);
    NewDwells.mean(i+1)  = mean(data);
    NewDwells.std(i+1)   = std(data);

    status='split'; %the new dwell has been split
    i=i+1; %increment counter, move over to the next one
%  elseif strcmp(VerdictOld,'same')

    %overlap is compatible with the old dwell
    %if the Std drops in both the current and previous NewDwells, proceed
    %with the merger, otherwise make the overlap an independent step
    

%     %disp('    GheDealWithSignificantStartOverlap: Overlap belongs to the old dwell');
%     %update current dwell accordingly
%     NewDwells.start(i) = OldDwells.end(OverlapInd(k))+1; 
%     %current new dwell starts immediately after the old dwell ends
%     %the end of the current new dwell remains the same
%     data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
%     NewDwells.Npts(i)  = length(data);
%     NewDwells.mean(i)  = mean(data); 
%     NewDwells.std(i)   = std(data);
% 
%     if i~=1 %if there is a previous new dwell, update it accordingly
%         NewDwells.end(i-1) = NewDwells.start(i)-1;
%         data = phageData.contour(NewDwells.start(i-1):NewDwells.end(i-1));
%         NewDwells.Npts(i-1)= length(data);
%         NewDwells.mean(i-1)= mean(data);
%         NewDwells.std(i-1) = std(data);
%     end
%     
%    status='split'; %the new dwell has been split
    %no need to increment i, keep reviewing the same new dwell 'i'
% else
    %disp('    GheDealWithSignificantStartOverlap: Overlap belongs to the new dwell');
    %overlap belongs to the new dwell
    %no need to increment i, keep reviewing the same new dwell 'i'
%    k=k+1; %increment the counter for the overlapping OldDwells
end