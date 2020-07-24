function [ValidatedDwells LocalMaxima]= Adaptive_ValidateDwells_FragDwellInd_Validate(CandidateDwells, LocalMaxima, MaxSeparation)
    % CandidateDwells(cd).Start
    % CandidateDwells(cd).Finish
    % CandidateDwells(cd).Mean  
    % CandidateDwells(cd).StartTime
    % CandidateDwells(cd).FinishTime
    % CandidateDwells(cd).DwellTime
    % CandidateDwells(cd).DwellLocation
    % CandidateDwells(cd).DwellForce
    %
    % LocalMaxima.KernelGrid
    % LocalMaxima.KernelValue
    % LocalMaxima.LocalMaxInd(m)
    % LocalMaxima.LeftLocalMinInd(m)
    % LocalMaxima.RightLocalMinInd(m)
    % LocalMaxima.Baseline(m)
    % LocalMaxima.PeakContrast(m)
    % LocalMaxima.IsValid(m)
    % LocalMaxima.LocalMinInd
    %
    % FiltT           - time vector at the bandwidth used for KV stepfinding
    % FiltY           - contour vector at the bandwidth used for KV stepfinding
    % ContrastThr     - used to identify the "valid peaks" in the landscape
    % CandidateDwells - contains all the info about the dwell/step candidated
    % MaxSeparation   - the peak shouldn't be any further than that from a candidate dwell location
    %
    % USE: ValidatedDwells = KV_TestingKernel_ValidatePeaks(FiltT,FiltY,CandidateDwells,LocalMaxima,MaxSeparation)
    %
    % Gheorghe Chistol, 30 June 2011
    
    
    % Use the LocalMaxima to validate the nearest CandidateDwell
    ValidatedDwellInd = []; %the index (with respect to CandidateDwells) of the Dwells that have been validated
    NearestPeakInd    = []; %the index of the peak nearest to the current validated dwells

    for cd = 1:length(CandidateDwells)
        %find the validated peak that is closest to the currDwellLocation
        currDwellLocation = CandidateDwells(cd).DwellLocation; %the location of the current dwell
        NearestPeakDist   = 1e6; %some random large number for start

        %go through all LocalMaxima
        for m=1:length(LocalMaxima.LocalMaxInd) %m stands for "Local Maximum"
            if LocalMaxima.IsValid(m)
                currPeakLocation = LocalMaxima.KernelGrid(LocalMaxima.LocalMaxInd(m));
                tempSeparation   = abs(currPeakLocation-currDwellLocation); %separation between the currentPeak and the currentDwell
                if tempSeparation < NearestPeakDist %the current Dwell is closer than the previously closest Dwells
                    NearestPeakDist    = tempSeparation;
                    tempNearestPeakInd = m;
                end
            end
        end

        if NearestPeakDist < MaxSeparation
            ValidatedDwellInd(end+1) = cd; %this dwell is close enough to the current peak, validated dwell
            NearestPeakInd(end+1)    = tempNearestPeakInd; %record the peak that is closest to this dwell
        end
    end

    ValidatedDwells = CandidateDwells(ValidatedDwellInd);
end

%             % In some cases, there are two consecutive validated dwells that in fact
%             % correspond to the same Valid Peak and should technically be within the
%             % same dwell. Here we are going to use NearestPeakInd to find those cases
%             % and merge them. Only merge temporally consecutive ValidatedDwells.
% 
%             %Find where multiple ValidatedDwells correspond to the same Peak
%             ValidDwellPerPeakCount = histc(NearestPeakInd,unique(NearestPeakInd));
%             UniqueNearestPeakInd   = unique(NearestPeakInd);
%             LocalMaxima.NearestPeakInd = UniqueNearestPeakInd; %save this information
% 
%             for unpi = 1:length(UniqueNearestPeakInd) %unpi - unique nearest peak index
%                 if ValidDwellPerPeakCount(unpi)==2 %we got two valid dwells for this one peak
%                     %merge the two dwells, but only if they are temporally consecutive
%                     PeakInd = UniqueNearestPeakInd(unpi); %current peak index
%                     temp = find(NearestPeakInd==PeakInd);
%                     %temp contains two entries corresponding to two dwells
%                     %temp(1)-th and temp(2)-th members of ValidatedDwells could potentially be merged if they are consecutive in time
%                     d1 = min(temp); d2 = max(temp);
% 
%                     if ValidatedDwells(d1).Finish+1==ValidatedDwells(d2).Start
%                         %they are temporally consecutive, merge
%                         ValidatedDwells(d1).MergeStatus       = 1; %this shows that the current dwell is the product of merging of other dwells
%                         ValidatedDwells(d1).PrecursorDwell{1} = ValidatedDwells(d1); %may be used later for consistency checks
%                         ValidatedDwells(d1).PrecursorDwell{2} = ValidatedDwells(d2);
%                         ValidatedDwells(d1).Finish            = ValidatedDwells(d2).Finish; %start remains unmodified
%                         ValidatedDwells(d1).FinishTime        = ValidatedDwells(d2).FinishTime; %start remains unmodified
%                         ValidatedDwells(d1).DwellTime         = ValidatedDwells(d1).FinishTime-ValidatedDwells(d1).StartTime;
%                         ValidatedDwells(d1).Mean              = mean(FiltY(ValidatedDwells(d1).Start:ValidatedDwells(d1).Finish));
%                         ValidatedDwells(d1).DwellLocation     = ValidatedDwells(d1).Mean;
%                         ValidatedDwells(d2)                   = []; %remove the dwell, it's been merged already
%                     end
%                 end
%             end
%
%     %% Tag the Very First and Very Last Validated Dwells if they start/end right at the beginning or right at the end
%     %basically, if the dwell starts right at the beginning of the feedback
%     %cycle, we can't use the dwell-time value, but we can still use the step
%     %size. The same applies to the very last dwell
% 
%     if length(ValidatedDwells)>1
%         if ValidatedDwells(1).Start == 1
%             ValidatedDwells(1).IsVeryFirst = 1;
%         end
% 
%         if ValidatedDwells(end).Finish == length(FiltY)
%             ValidatedDwells(end).IsVeryLast = 1;
%         end
%     end
