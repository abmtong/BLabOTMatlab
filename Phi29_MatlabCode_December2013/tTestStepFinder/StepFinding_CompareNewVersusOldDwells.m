function NewDwells = StepFinding_CompareNewVersusOldDwells(Data,OldDwells,NewDwells,BinThr)
% Compare every single "new" dwell against the "old" dwells, keep the old
% dwells if they fit the data better, or vice-versa.
%
% USE: NewDwells = StepFinding_CompareNewVersusOldDwells(Data,OldDwells,NewDwells,BinThr)
%
% Gheorghe Chistol, 16 March 2011

%The data structure NewDwells will not stay constant in size, since we may
%delete or add new dwells, so use the "while" instead of "for".
i=1; %starting point - at the beginning
while i<=length(NewDwells.mean)
    DwellStatus='intact'; %the new dwell hasn't been split yet
    
    %Find old dwells that have any overlap with the current new dwell
    [OverlapInd, Overlap, Npts, NptsAbove] = StepFinding_FindOverlappingOldDwells(Data,OldDwells,NewDwells,i);
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
        else
            i=i+1;
        end
        
    elseif length(OverlapInd)==1
        %revised, June 10, 2010
        [NewDwells,i] = StepFinding_DealWithOnlyOneOverlap(Data,NewDwells,OldDwells,OverlapInd,BinThr,i);
        %i has been updated by the function above
        %disp('Got only one overlap');
    elseif length(OverlapInd)>1
        %disp(['Got ' num2str(length(OverlapInd)) ' overlaps.']);
        %We have more than one old dwells overlapping the new dwell
        
        % a. Partial Overlap at the beginning of the New Dwell
        % b. Complete Overlap in the middle of the New Dwell
        %   1. The very first complete overlapping Old Dwell is 'diff' from the current New Dwell
        %   2. Some complete overlapping Old Dwell in the middle is 'diff' from the current New Dwell
        %   3. The very last complete overlapping Old Dwell is 'diff' from the current New Dwell  
        % c. Partial Overlap at the end of the New Dwell
        
        k=1; %start at the very beginning
        while k<=length(OverlapInd) && ~strcmp(DwellStatus,'split') %go through the overlapping old dwells, as long as the new dwell hasn't been split
            clear Verdict;
            %Deal with partial overlap at the beginning
            if k==1 && sum(Overlap{k})<OldDwells.Npts(OverlapInd(k))
               %overlap is at the beginning (small or significant)
               %disp('Start Overlap');
               [NewDwells,i,k,DwellStatus]=StepFinding_DealWithStartOverlap(Data,NewDwells,OldDwells,OverlapInd,i,k);
            elseif sum(Overlap{k})==OldDwells.Npts(OverlapInd(k)) && ~strcmp(DwellStatus,'split')
               %we have a complete overlap
               %disp('Middle Overlap');
               [NewDwells,i,k,DwellStatus]=StepFinding_DealWithMiddleOverlap(Data,NewDwells,OldDwells,OverlapInd,i,k);
            elseif k==length(OverlapInd) && sum(Overlap{k})<OldDwells.Npts(OverlapInd(k)) && ~strcmp(DwellStatus,'split')
               % Deal with partial overlap at the end
               %disp('End Overlap');
               [NewDwells,i,k,DwellStatus]=StepFinding_DealWithEndOverlap(PhageData,NewDwells,OldDwells,OverlapInd,i,k);
            end
        end
    end
end
%Update the StepSize Values
for s=1:length(NewDwells.mean)-1
    NewDwells.StepSize(s) = NewDwells.mean(s+1)-NewDwells.mean(s);
end