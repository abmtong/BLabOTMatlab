function [NewDwells,i,k,status]=GheDealWithSmallStartOverlap(phageData,NewDwells,OldDwells,OverlapInd,i,k,status)
% OverlapInd(k) is the index of the overlapping old dwell under review
% Use: [NewDwells,i,k,status]=GheDealWithSmallStartOverlap(phageData,NewDwells,OldDwells,OverlapInd,i,k,status)
% Revised June 10, 2010
% Revised June 14, 2010
%
% Gheorghe Chistol, June 01, 2010

%Partial overlap is very small at the beginning of the new dwell
StdNewComplete  = NewDwells.std(i);
StdOldComplete  = OldDwells.std(OverlapInd(k));
StartOldShorter = OldDwells.start(OverlapInd(k)); %the same
EndOldShorter   = NewDwells.start(i)-1; %ends right before the complete new dwell starts
StartNewShorter = OldDwells.end(OverlapInd(k))+1; %starts after the complete old dwell ends
EndNewShorter   = NewDwells.end(i); %same
StdNewShorter   = std(phageData.contour(StartNewShorter:EndNewShorter));
StdOldShorter   = std(phageData.contour(StartOldShorter:EndOldShorter));

%OldShorter - shortened at the end till the start of the new dwell
%NewShorter - shortened at the beginning, from the end of the old dwell
%comparing OldAfter/NewBefore vs OldBefore/NewAfter
if StdOldShorter<=StdOldComplete && StdNewComplete<=StdNewShorter
    %The Shorter Old Dwell fits data better AND The Complete New Dwell fits data better
    %Overlap belongs to the complete new dwell
    %disp('    GheDealWithSmallStartOverlap: Shorter Old Dwell and Complete New Dwell fit data better');
    k=k+1; %increment counter for the overlapping Old Dwells, keep reviewing the current new dwell 'i'
    %no need to increment i, keep reviewing the current new dwell 'i'
elseif StdNewShorter<=StdNewComplete && StdOldComplete<=StdOldShorter
    %The Shorter New Dwell fits data better AND the Complete Old Dwell fits data better
    %Overlap belongs to the complete old dwell
    k=k+1; %increment the counter for the old dwell, we're done working with it
    %disp('    GheDealWithSmallStartOverlap: Complete Old Dwell & Shorter New Dwell fit data better');
    NewDwells.start(i) = StartNewShorter; %the end remains the same though
    data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
    NewDwells.Npts(i)  = length(data);
    NewDwells.mean(i)  = mean(data);
    NewDwells.std(i)   = std(data);
    
    if i~=1 %if there are previous new dwells
        %Update the previous new dwell accordingly
        NewDwells.end(i-1) = NewDwells.start(i)-1;
        data = phageData.contour(NewDwells.start(i-1):NewDwells.end(i-1));
        NewDwells.Npts(i-1)  = length(data);
        NewDwells.mean(i-1)  = mean(data);
        NewDwells.std(i-1)   = std(data);
    end
    status='split'; %change the status to split, time to re-calculate the overlapping old dwells
    %disp('    GheDealWithSmallStartOverlap: The new dwell has been split');
    %no need to increment i, keep reviewing the current new dwell 'i'
else
    %just keep the new dwell
    k=k+1;
%     %One std goes down while the other one goes up, it's not
%     %clear whether we have an improvment
%     
%     if (StdNewComplete-StdNewShorter)>(StdOldComplete-StdOldShorter)
%         %The new shorter dwell improves more than the old shorter dwell
%         %Overlap belongs to the old complete dwell
%         disp('    GheDealWithSmallStartOverlap: New Shorter Dwell improves more than the Old Shorter Dwell');
%         k=k+1; %increment the counter for the old dwell, we're done working with it
%         NewDwells.start(i) = StartNewShorter; %the end remains the same though
%         data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
%         NewDwells.Npts(i)  = length(data);
%         NewDwells.mean(i)  = mean(data);
%         NewDwells.std(i)   = std(data);
% 
%         if i~=1 %if there is a previous new dwell, update it accordingly
%             NewDwells.end(i-1) = NewDwells.start(i)-1;
%             data = phageData.contour(NewDwells.start(i-1):NewDwells.end(i-1));
%             NewDwells.Npts(i-1)  = length(data);
%             NewDwells.mean(i-1)  = mean(data);
%             NewDwells.std(i-1)   = std(data);
%         end
%         status='split'; %the new dwell has been split
%         disp('    GheDealWithSmallStartOverlap: The new dwell has been split');
%         %no need to increment i, keep reviewing the current new dwell 'i'
%     else
%         %The old shorter dwell improves more than the new shorter dwell
%         %Overlap belongs to the new complete dwell
%         k=k+1; %increment counter for the overlapping Old Dwells
%         %no need to increment i, keep reviewing the current new dwell 'i'
%         disp('    GheDealWithSmallStartOverlap: Old Shorter Dwell improves more than the New Shorter Dwell');
%     end
end