function [OverlapInd, Overlap, Npts, NptsAbove] = FindOverlappingOldDwells(PhageData, OldDwells, NewDwells, i, FeedbackCycle)
% This function finds old dwells that have any overlap with the (i)th NewDwell.
%
% OverlapInd(): contains the indices of the old dwells that overlap
% Npts():        # of points in each old dwell 
% NptsAbove():   # of points in each old dwell above the mean of the new dwell
% Overlap{}:     the overlap vector between the old dwell and the new dwell
%
% USE: [OverlapInd, Overlap, Npts, NptsAbove] = FindOverlappingOldDwells(phageData, OldDwells, NewDwells, i, FeedbackCycle)
%
% Gheorghe Chistol, 25 Oct 2010

%Create a vector with ones where the new dwell exists and zeros everywhere else
NewVector = zeros(1,length(PhageData.contourFiltered{FeedbackCycle})); %create zero vector
NewVector(NewDwells.start(i):NewDwells.end(i))=1; %put ones where the new dwell exists

for j=1:length(OldDwells.mean) %find Old Dwells overlapping the New Dwell
    %make a vector the length of the entire phageData.contour data
    %have ones where the OldDwells(j) exists, and zeros everywhere else.
    %Dot this vector with the corresponding vector for the
    %NewDwells(i). The non-zero entries of this dotted product should
    %give you the overlap between the two.
    OldVector = zeros(1,length(PhageData.contourFiltered{FeedbackCycle})); %create zero vector
    OldVector(OldDwells.start(j):OldDwells.end(j))=1; %put ones where the old dwell exists
    temp = NewVector.*OldVector; %the non-zero entries correspond to the points where the old and the new dwells overlap

    %if we have any overlap, we can investigate further,
    %save the overlap data in the Overlap data structure
    if sum(temp)>0
        if ~exist('OverlapInd','var') %if Overlap data structure is non-existent, create it
            OverlapInd(1) = j; %the index of the old dwell
            Overlap{1} = temp; %overlap vector
            Npts(1) = OldDwells.Npts(j);
            start  = OldDwells.start(j);
            finish = OldDwells.end(j);
            data = PhageData.contourFiltered{FeedbackCycle}(start:finish);
            NptsAbove(1) = length(find(data>NewDwells.mean(i))); %# of pts from the old dwell that are above the mean of the new dwell
        else
            %append at the end of the existing data structure
            OverlapInd(end+1)=j;
            Overlap{end+1}=temp; 
            Npts(end+1) = OldDwells.Npts(j);
            start  = OldDwells.start(j);
            finish = OldDwells.end(j);
            data = PhageData.contourFiltered{FeedbackCycle}(start:finish);
            NptsAbove(end+1) = length(find(data>NewDwells.mean(i))); %# of pts from the old dwell that are above the mean of the new dwell
        end
    end
end
%if no overlap was found
if ~exist('OverlapInd','var')
    %create empty data sructures/vectors
    Overlap={};
    OverlapInd=[];
    Npts=[];
    NptsAbove=[];
end
