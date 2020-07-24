function ValidatedDwells = KV_ValidateDwells(FiltT, FiltY, CandidateDwells, LocalMaxima, MaxSeparation)
    % CandidateDwells(cd).Start
    % CandidateDwells(cd).Finish
    % CandidateDwells(cd).Mean  
    % CandidateDwells(cd).StartTime
    % CandidateDwells(cd).FinishTime
    % CandidateDwells(cd).DwellTime
    % CandidateDwells(cd).DwellLocation
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
    
    ValidatedDwells = KV_ValidateDwells_Validate(FiltT, FiltY, CandidateDwells, LocalMaxima, MaxSeparation);

%     for vd = 1:length(ValidatedDwells)
%         plot(get(gca,'XLim'),[1 1]*ValidatedDwells(vd).DwellLocation,'y');
%     end
    %% Proceed to resolve Valid-Unvalid-Valid situations
    % Where an unvalidated dwell is sandwiched between two validated dwells.
    % Here we can split the unvalidated dwell between its neighbors.
    ValidatedDwells = KV_ValidateDwells_ResolveValidUnvalidValid(CandidateDwells,ValidatedDwells,LocalMaxima,FiltT,FiltY);
    
    %% Tag the Very First and Very Last Validated Dwells if they start/end right at the beginning or right at the end
    %basically, if the dwell starts right at the beginning of the feedback
    %cycle, we can't use the dwell-time value, but we can still use the step
    %size. The same applies to the very last dwell

    if length(ValidatedDwells)>1
        if ValidatedDwells(1).Start == 1
            ValidatedDwells(1).IsVeryFirst = 1;
        end

        if ValidatedDwells(end).Finish == length(FiltY)
            ValidatedDwells(end).IsVeryLast = 1;
        end
    end

    %% If there are any isolated Dwells, remove them completely, 
    % They are not useful since we're not all that sure about their duration
    % and they don't have a valid step-size associated with them
    ValidatedDwells = KV_ValidateDwells_RemoveIsolatedValidatedDwells(ValidatedDwells);
end