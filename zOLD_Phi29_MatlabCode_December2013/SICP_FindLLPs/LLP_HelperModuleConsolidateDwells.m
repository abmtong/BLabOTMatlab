function DwellInd = LLP_HelperModuleConsolidateDwells(DwellInd,Bandwidth,FiltY,MinStep,MinDuration)
% DwellInd(d).Start  - dwell start  index in terms of FiltY
% DwellInd(d).Finish - dwell finish index in terms of FiltY
% DwellInd(d).Mean   
%
% This function identifies very short dwells (shorter than MinDuration) and
% tries to incorporate them into the nearest neighbor (nearest by mean). In
% addition, this function looks if there are any dwells that are too close
% to each other (closer thn MinStep) and merges them if they are closer than MinStep.
% At the end, it gets rid of very short dwells right at the beginning or at
% the end of the subtrace (when the feedback kicked in). 
% Use:  DwellInd = LLP_HelperModuleConsolidateDwells(DwellInd,Bandwidth,FiltY,MinStep,MinDuration)
%
% Gheorghe Chistol, 01 Dec 2012

%% Getting Rid of the Dwells Separated by Very Small Step Sizes (Smaller than MinStep)
%repeat cycles of dwell consolidation until no more consolidation can be
%done. This is needed because sometimes one round of consolidation is not
%enough.

Status = 'Initialize'; %status of the dwell consolidation process
while ~strcmp(Status,'NoChanges')
    Status = 'NoChanges'; %if there is any consolidation, the status will change
    i=1; %initialize the dwell counter 
    while i<=length(DwellInd) %go through the updated dwells, merge dwells going forward
        %DeltaNext is the mean difference of the current and the next dwell
        %DeltaPrev is the mean difference of the current and the previous dwell
        if i==1 %the very first dwell
            DeltaPrev = 1e5; %there is no prev dwell, set a giant number
        else
            DeltaPrev = abs(DwellInd(i).Mean-DwellInd(i-1).Mean); %take abs value
        end

        if i==length(DwellInd) %the very last dwell
            DeltaNext = 1e5; %there is no next dwell, set a giant number
        else
            DeltaNext = abs(DwellInd(i).Mean-DwellInd(i+1).Mean); %take abs value
        end

        if (DeltaNext<=MinStep)
            if (DeltaPrev<=MinStep) && (DeltaPrev<DeltaNext)
                %this means that the previous dwell is too close and it makes more
                %sense to merge the current dwell with the previous one
                Status='Merged'; disp('-> -> Merged with previous dwell');
                tempY = FiltY(DwellInd(i-1).Start:DwellInd(i).Finish); %contour length data from the trace corresponding to the merged dwell 
                DwellInd(i-1).Mean   = mean(tempY); %update values based on saved contour data             
                DwellInd(i-1).Finish = DwellInd(i).Finish; %DwellInd(i-1).Start remains unchanged 
                DwellInd(i)          = []; %remove the ith dwell
                %the counter "i" remains unchanged due to merging with prev dwell
            else
                %merge the current dwell with the next one
                Status='Merged'; disp('-> -> Merged with next dwell');
                tempY = FiltY(DwellInd(i).Start:DwellInd(i+1).Finish);
                DwellInd(i).Mean   = mean(tempY); %update values based on saved contour data             
                DwellInd(i).Finish = DwellInd(i+1).Finish; %DwellInd(i).Start remains unchanged 
                DwellInd(i+1)      = []; %remove the ith dwell
                i=i+1; %increase counter, move to the next dwell
            end
        elseif (DeltaPrev<=MinStep) %if the previous step is too close, proceed to merging
            Status='Merged'; disp('-> -> Merged with previous dwell');
            tempY = FiltY(DwellInd(i-1).Start:DwellInd(i).Finish); %contour length data from the trace corresponding to the merged dwell 
            DwellInd(i-1).Mean   = mean(tempY); %update values based on saved contour data             
            DwellInd(i-1).Finish = DwellInd(i).Finish; %DwellInd(i-1).Start remains unchanged 
            DwellInd(i)          = []; %remove the ith dwell
            %the counter "i" remains unchanged due to merging with prev dwell
        else %if the dwell has the proper duration, keep it unchanged
            i=i+1; %move over to the next dwell and repeat the procedure
        end
    end

    %% Getting Rid of the Short Dwells (both forward and backward)
    i=1; %initialize the counter
    while i<=length(DwellInd) %go through each dwell and check its duration going
        if (DwellInd(i).Finish-DwellInd(i).Start)*(1/Bandwidth)<MinDuration %if the dwell is too short
            if i==1 %the very first dwell
                DeltaPrev = 1e5; %random large number, there is no previous dwell
            else
                DeltaPrev = abs(DwellInd(i).Mean-DwellInd(i-1).Mean); %take abs value
            end

            if i==length(DwellInd) %the very last dwell
                DeltaNext = 1e5; %there is no next dwell, set a giant number
            else
                DeltaNext = abs(DwellInd(i).Mean-DwellInd(i+1).Mean); %take abs value
            end

            if (DeltaNext<=DeltaPrev) %if the next dwell is closer
                %merge the current dwell with the next one
                Status='Merged'; disp('-> -> Merged short dwell with next dwell');
                tempY = FiltY(DwellInd(i).Start:DwellInd(i+1).Finish);
                DwellInd(i).Mean   = mean(tempY); %update values based on saved contour data             
                DwellInd(i).Finish = DwellInd(i+1).Finish; %DwellInd(i).Start remains unchanged 
                DwellInd(i+1)      = []; %remove the ith dwell
                i=i+1; %increase counter, move to the next dwell
            else %if the previous dwell is closer
                 %merge the current dwell with the previous dwell
                 if i~=1
                    Status='Merged'; disp('-> -> Merged short dwell with previous dwell');
                    tempY = FiltY(DwellInd(i-1).Start:DwellInd(i).Finish); %contour length data from the trace corresponding to the merged dwell 
                    DwellInd(i-1).Mean   = mean(tempY); %update values based on saved contour data             
                    DwellInd(i-1).Finish = DwellInd(i).Finish; %DwellInd(i-1).Start remains unchanged 
                    DwellInd(i)          = []; %remove the ith dwell
                    %the counter "i" remains unchanged due to merging with prev dwell
                 end
            end
        else %if the dwell has the proper duration, keep it unchanged
            i=i+1; %move over to the next dwell and repeat the procedure
        end
    end
end
end