function FinalDwellsValidated = KV_FinalDwellsValidated(ValidatedFragDwellInd,RawT,RawY,FiltT,FiltY,PhageFileName,FeedbackCycle,Bandwidth)
    % Organize the data contained in ValidatedFragDwellInd into a new structure -
    % FinalDwellsValidated, which will ultimately be saved in the results
    % file
    %
    % ValidatedFragDwellInd{f}(d).StartTime
    % ValidatedFragDwellInd{f}(d).FinishTime
    % ValidatedFragDwellInd{f}(d).DwellTime
    % ValidatedFragDwellInd{f}(d).DwellLocation
    %
    % USE: FinalDwellsValidated = KV_FinalDwellsValidated(ValidatedFragDwellInd,RawT,RawY,FiltT,FiltY,PhageFileName,FeedbackCycle,Bandwidth)
    %
    % Gheorghe Chistol, 6 July 2011
    FinalDwellsValidated.Start          = [];
    FinalDwellsValidated.Finish         = [];
    FinalDwellsValidated.StartTime      = [];
    FinalDwellsValidated.FinishTime     = [];
    FinalDwellsValidated.DwellTime      = [];
    FinalDwellsValidated.DwellLocation  = [];
    FinalDwellsValidated.StepSize       = [];
    FinalDwellsValidated.StepLocation   = [];
    
    for f=1:length(ValidatedFragDwellInd)
        for d=1:length(ValidatedFragDwellInd{f})
            FinalDwellsValidated.Start(end+1)         = ValidatedFragDwellInd{f}(d).Start; %#ok<*AGROW>
            FinalDwellsValidated.Finish(end+1)        = ValidatedFragDwellInd{f}(d).Finish;
            FinalDwellsValidated.StartTime(end+1)     = ValidatedFragDwellInd{f}(d).StartTime;
            FinalDwellsValidated.FinishTime(end+1)    = ValidatedFragDwellInd{f}(d).FinishTime;
            FinalDwellsValidated.DwellLocation(end+1) = ValidatedFragDwellInd{f}(d).DwellLocation;
            FinalDwellsValidated.DwellTime(end+1)     = ValidatedFragDwellInd{f}(d).DwellTime;
            %Technically, the very first and very last dwells don't give us a
            %reliable dwell time, so we discard them (part of the dwell may be
            %cutoff but he beginning/end of the feedback cycle. At the same time,
            %those dwells can still give us a decent burst-size measurement
            % for more see KV_PlotStepStaircase_ValidatePeaks.m

            if isfield(ValidatedFragDwellInd{f}(d),'IsVeryFirst')
                if ValidatedFragDwellInd{f}(d).IsVeryFirst == 1
                   %ValidatedFragDwellInd{f}(d).DwellTime = NaN;
                   disp('invalidated very first dwell');
                end
            end

            if isfield(ValidatedFragDwellInd{f}(d),'IsVeryLast')
                if ValidatedFragDwellInd{f}(d).IsVeryLast == 1
                   %ValidatedFragDwellInd{f}(d).DwellTime = NaN;
                   disp('invalidated very last dwell');
                end
            end

        end
    end
    
    %% Step Size Calculation
    % A valid step-size can be calculated only between two temporally
    % consecutive validated dwells. Any other dwell will have a NaN for StepSize
    for f = 1:length(ValidatedFragDwellInd)
        for vd = 1:length(ValidatedFragDwellInd{f})-1 %we can't calculate the step-size after the last dwell
            if ValidatedFragDwellInd{f}(vd).Finish+1 == ValidatedFragDwellInd{f}(vd+1).Start
                FinalDwellsValidated.StepSize(end+1)     = ValidatedFragDwellInd{f}(vd).DwellLocation - ValidatedFragDwellInd{f}(vd+1).DwellLocation;     %this step size should be positive for a regular burst
                FinalDwellsValidated.StepLocation(end+1) = (ValidatedFragDwellInd{f}(vd+1).DwellLocation + ValidatedFragDwellInd{f}(vd).DwellLocation)/2; %where along DNA did this step occur?
            else
                FinalDwellsValidated.StepSize(end+1)     = NaN;
                FinalDwellsValidated.StepLocation(end+1) = NaN;
            end
        end
        FinalDwellsValidated.StepSize(end+1)     = NaN;
        FinalDwellsValidated.StepLocation(end+1) = NaN;
    end

    FinalDwellsValidated.PhageFile     = PhageFileName; %file name
    FinalDwellsValidated.FeedbackCycle = FeedbackCycle; %trace ID
    FinalDwellsValidated.Bandwidth     = Bandwidth; %bandwidth
    FinalDwellsValidated.RawCont       = RawY;
    FinalDwellsValidated.RawTime       = RawT;
    FinalDwellsValidated.FiltCont      = FiltY;
    FinalDwellsValidated.FiltTime      = FiltT;
    
end