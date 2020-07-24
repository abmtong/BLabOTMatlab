function [NewDwells, i, k, status ] = GheDealWithSmallEndOverlap(phageData, NewDwells, OldDwells, OverlapInd, i, k, status)
%This is a script which is part of the GheCompareNewVersusOldDwells.m
%function, but I had to take it out separately for readability reasons.
% Revised Gheorghe Chistol, June 10, 2010
%
%Gheorghe Chistol, May 31, 2010

%Partial overlap is very small at the end of the new dwell
StdNewComplete  = NewDwells.std(i);
StdOldComplete  = OldDwells.std(OverlapInd(k));

StartOldShorter = NewDwells.end(i)+1; %starts right after the new dwell ends
EndOldShorter   = OldDwells.end(OverlapInd(k)); %the same

StartNewShorter = NewDwells.start(i); %same
EndNewShorter   = OldDwells.start(OverlapInd(k))-1; %ends right before the old dwell starts

StdNewShorter   = std(phageData.contour(StartNewShorter:EndNewShorter));
StdOldShorter   = std(phageData.contour(StartOldShorter:EndOldShorter));

%OldShorter - shortened at the beginning; starts from the of the new dwell
%NewShorter - shortened at the end; ends right before the beginning the complete old dwell
%comparing OldAfter/NewBefore vs OldBefore/NewAfter
if StdOldShorter<=StdOldComplete && StdNewComplete<=StdNewShorter
    %The Shorter Old Dwell fits data better AND
    %The Complete New Dwell fits data better
    %Overlap belongs to the complete new dwell
    disp('    GheDealWithSmallEndOverlap: Overlap belongs to the current New Dwell');
    k=k+1; %increment counter for the overlapping Old Dwells
    i=i+1; %new dwell is good, keep going
    
elseif StdNewShorter<=StdNewComplete && StdOldComplete<=StdOldShorter
    % The Shorter New Dwell fits data better AND
    % The Complete Old Dwell fits data better
    % Overlap belongs to the complete old dwell
    % End the current new dwell prematurely (before the old dwell starts)
    if i~=length(NewDwells.mean) 
        % We are not at the last curent dwell
        % The small piece leftover gets merged with the next new dwell
        disp('    GheDealWithSmallEndOverlap: Overlap belongs to Old Dwell, NewDwell has been shortened by a bit');

        %shorten the current new dwell; the start remains the same
        NewDwells.end(i)   = OldDwells.start(OverlapInd(k))-1; %ends right before the old dwell starts
        data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
        NewDwells.Npts(i)  = length(data);
        NewDwells.mean(i)  = mean(data);
        NewDwells.std(i)   = std(data);

        %update the next New Dwell accordingly
        NewDwells.start(i+1) = NewDwells.end(i)+1; %starts where the prev one ended
        %the end remains unchanged
        data = phageData.contour(NewDwells.start(i+1):NewDwells.end(i+1));
        NewDwells.Npts(i+1)  = length(data);
        NewDwells.mean(i+1)  = mean(data);
        NewDwells.std(i+1)   = std(data);
        i=i+1;
        k=k+1;
        status='split'; %the current new dwell has been split
    else
        % @ The last Current Dwell, just end current dwell prematurely
        NewDwells.end(i)   = OldDwells.start(OverlapInd(k))-1; %ends right before the old dwell starts
        data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
        NewDwells.Npts(i)  = length(data);
        NewDwells.mean(i)  = mean(data);
        NewDwells.std(i)   = std(data);

        disp('    GheDealWithSmallEndOverlap: NewDwell has been shortened by a bit, Overlap @ the very end of trace, discarded');
        i=i+1;
        k=k+1;
        status='split';
    end
else
    %One std goes down while the other one goes up, it's not
    %clear whether we have an improvment
    if (StdNewComplete-StdNewShorter)>(StdOldComplete-StdOldShorter)
        %The new shorter dwell improves more than the old shorter dwell
        %Overlap belongs to the old complete dwell
        if i~=length(NewDwells.mean) 
            % We are not at the last New Dwell
            % The small piece leftover gets merged with the next new dwell
            disp('    GheDealWithSmallEndOverlap: Overlap belongs to Old Dwell, NewDwell has been shortened by a bit');

            %shorten the current new dwell; the start remains the same
            NewDwells.end(i)   = OldDwells.start(OverlapInd(k))-1; %ends right before the old dwell starts
            data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
            NewDwells.Npts(i)  = length(data);
            NewDwells.mean(i)  = mean(data);
            NewDwells.std(i)   = std(data);

            %update the next New Dwell accordingly
            NewDwells.start(i+1) = NewDwells.end(i)+1; %starts where the prev one ended
            %the end remains unchanged
            data = phageData.contour(NewDwells.start(i+1):NewDwells.end(i+1));
            NewDwells.Npts(i+1)  = length(data);
            NewDwells.mean(i+1)  = mean(data);
            NewDwells.std(i+1)   = std(data);
            i=i+1;
            k=k+1;
            status='split'; %the current new dwell has been split
        else
            % @ The last Current Dwell, just end current dwell prematurely
            NewDwells.end(i)   = OldDwells.start(OverlapInd(k))-1; %ends right before the old dwell starts
            data = phageData.contour(NewDwells.start(i):NewDwells.end(i));
            NewDwells.Npts(i)  = length(data);
            NewDwells.mean(i)  = mean(data);
            NewDwells.std(i)   = std(data);

            disp('    GheDealWithSmallEndOverlap: NewDwell has been shortened by a bit, Overlap @ the very end of trace, discarded');
            i=i+1;
            k=k+1;
            status='split';
        end
    else
        %The old shorter dwell improves more than the new shorter dwell
        %Overlap belongs to the new complete dwell
        disp('    GheDealWithSmallEndOverlap: Overlap belongs to the current New Dwell');
        k=k+1; %increment counter for the overlapping Old Dwells
        i=i+1; %increment counter for the new dwell, we're done here
    end
end