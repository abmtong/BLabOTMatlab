function NewDwells=GheCompareNewVersusOldDwells(PhageData, OldDwells, NewDwells, BinThr, Nmin)
% Compare every single "new" dwell against the "old: dwells, keep the old
% dwells if they fit the data better, or vice-versa.
%
% USE: NewDwells=GheCompareNewVersusOldDwells(PhageData, OldDwells, NewDwells, BinThr, Nmin)
%
% Gheorghe Chistol, May 30, 2010
% Gheorghe Chistol, June 09, 2010
% Gheorghe Chistol, June 14, 2010

%The data structure NewDwells will not stay constant in size, since we may
%delete or add new dwells, so use the "while" instead of "for".
i=1; %starting point - at the beginning
while i<=length(NewDwells.mean)
    DwellStatus='intact'; %the new dwell hasn't been split yet
    
    %Find old dwells that have any overlap with the current new dwell
    [OverlapInd, Overlap, Npts, NptsAbove] = GheFindOverlappingOldDwells(PhageData, OldDwells, NewDwells, i);
    %OverlapInd(): index of old dwells that overlap the current new dwell
    %Overlap{}:    vector with '1' where the old dwell overlaps the new dwell
    %Npts():       # of pts in the respective old dwell
    %NptsAbove():  # of points in each old dwell above the mean of the new dwell 

    if isempty(OverlapInd)
        %if there is no overlap with any old dwell (highly unlikely)
        %keep the new dwell, nothing changes, increment the new dwell counter
        %disp('Got No Overlap with any old Dwell');
        if NewDwells.Npts(i)==0
            NewDwells.start(i)=[];
            NewDwells.end(i)=[];
            NewDwells.Npts(i)=[];
            NewDwells.mean(i)=[];
            NewDwells.std(i)=[];
            %disp('Came across an empty dwell, removing it');
        else
            i=i+1;
        end
        
    elseif length(OverlapInd)==1
        %revised, June 10, 2010
        [NewDwells,i] = GheDealWithOnlyOneOverlap(PhageData,NewDwells,OldDwells,OverlapInd,BinThr,Nmin,i);
        %i has been updated by the function above
        %disp('Got only one overlap');
    elseif length(OverlapInd)>1
        %disp(['Got ' num2str(length(OverlapInd)) ' overlaps.']);
        %We have more than one old dwells overlapping the new dwell
        
        % a. Partial Overlap at the beginning of the New Dwell
        %   1. Overlap is very small and belongs to the OldDwell
        %   2. Overlap is very small and belongs to the New Dwell
        %   3. Overlap is significant and belongs to the Old Dwell
        %   4. Overlap is significant and belongs to the New Dwell
        %   5. Overlap is significant and is distinct from either Old or New Dwell
        % b. Complete Overlap in the middle of the New Dwell
        %   1. The very first complete overlapping Old Dwell is 'diff' from the current New Dwell
        %   2. Some complete overlapping Old Dwell in the middle is 'diff' from the current New Dwell
        %   3. The very last complete overlapping Old Dwell is 'diff' from the current New Dwell  
        % c. Partial Overlap at the end of the New Dwell
        %   1. Overlap is very small and belongs to the OldDwell
        %   2. Overlap is very small and belongs to the New Dwell
        %   3. Overlap is significant and belongs to the Old Dwell
        %   4. Overlap is significant and belongs to the New Dwell
        %   5. Overlap is significant and is distinct from either Old or New Dwell
        
        k=1; %start at the very beginning
        while k<=length(OverlapInd) && ~strcmp(DwellStatus,'split') %go through the overlapping old dwells, as long as the new dwell hasn't been split
            clear Verdict;
            %Deal with partial overlap at the beginning
            if k==1 && sum(Overlap{k})<=Nmin && sum(Overlap{k})<OldDwells.Npts(OverlapInd(k))
               %partial overlap is at the beginning and is very small
               %disp('Got a small partial overlap at the beginning of the current new dwell');
               % Revised June 10
               [NewDwells, i, k, DwellStatus ] = GheDealWithSmallStartOverlap(PhageData, NewDwells, OldDwells, OverlapInd, i, k, DwellStatus);
               
            elseif k==1 && sum(Overlap{k})>Nmin && sum(Overlap{k})<OldDwells.Npts(OverlapInd(k))
               %overlap is at the beginning and is significant
               %disp('Got a significant partial overlap at the beginning of the current new dwell');
               % Revised June 10
               [NewDwells, i, k, DwellStatus ] = GheDealWithSignificantStartOverlap(PhageData, NewDwells, OldDwells, OverlapInd, BinThr, i, k, DwellStatus);
               
            elseif sum(Overlap{k})==OldDwells.Npts(OverlapInd(k)) && ~strcmp(DwellStatus,'split')
               %we have a complete overlap
               %disp('Got a complete overlap somewhere in the middle of the current New Dwell');
               %Revised June 10
               [NewDwells,i,k,DwellStatus]=GheDealWithCompleteOverlap(PhageData,NewDwells,OldDwells,OverlapInd,BinThr,i,k,DwellStatus,NptsAbove,Npts);
               
            elseif k==length(OverlapInd) && sum(Overlap{k})<OldDwells.Npts(OverlapInd(k)) && ~strcmp(DwellStatus,'split')
               % Deal with partial overlap at the end
               if sum(Overlap{k})<=Nmin
                   %disp('Small Partial Overlap @ the end of the current dwell');
                   % The Overlap is at the end and is very small
                   % Revised June 10
                   [NewDwells,i,k,DwellStatus]=GheDealWithSmallEndOverlap(PhageData,NewDwells,OldDwells,OverlapInd,i,k,DwellStatus);

               else
                   %disp('Significant Partial Overlap @ the end of the current dwell');
                   % Overlap is at the end and is significant
                   % Revised June 10
                   [NewDwells,i,k,DwellStatus]=GheDealWithSignificantEndOverlap(PhageData,NewDwells,OldDwells,OverlapInd,BinThr,i,k,DwellStatus);
               end
            end
        end
    end
end