function FinalDwellsValidated = Adaptive_FinalDwellsValidated(ValidatedFragDwellInd,FiltT,FiltY,FiltF,PhageFileName,FeedbackCycle,Bandwidth)
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
    FinalDwellsValidated.DwellForce     = [];
    FinalDwellsValidated.StepSize       = [];
    FinalDwellsValidated.StepLocation   = [];
    FinalDwellsValidated.StepForce      = [];
    
    for f=1:length(ValidatedFragDwellInd)
        for d=1:length(ValidatedFragDwellInd{f})
            FinalDwellsValidated.Start(end+1)         = ValidatedFragDwellInd{f}(d).Start; %#ok<*AGROW>
            FinalDwellsValidated.Finish(end+1)        = ValidatedFragDwellInd{f}(d).Finish;
            FinalDwellsValidated.StartTime(end+1)     = ValidatedFragDwellInd{f}(d).StartTime;
            FinalDwellsValidated.FinishTime(end+1)    = ValidatedFragDwellInd{f}(d).FinishTime;
            FinalDwellsValidated.DwellTime(end+1)     = ValidatedFragDwellInd{f}(d).DwellTime;
            FinalDwellsValidated.DwellLocation(end+1) = ValidatedFragDwellInd{f}(d).DwellLocation;
            FinalDwellsValidated.DwellForce(end+1)    = ValidatedFragDwellInd{f}(d).DwellForce;
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
                FinalDwellsValidated.StepForce(end+1)    = (ValidatedFragDwellInd{f}(vd+1).DwellForce + ValidatedFragDwellInd{f}(vd).DwellForce)/2; %what force did this step occur at?
            else
                FinalDwellsValidated.StepSize(end+1)     = NaN;
                FinalDwellsValidated.StepLocation(end+1) = NaN;
                FinalDwellsValidated.StepForce(end+1)    = NaN;
            end
        end
        FinalDwellsValidated.StepSize(end+1)     = NaN;
        FinalDwellsValidated.StepLocation(end+1) = NaN;
        FinalDwellsValidated.StepForce(end+1)    = NaN;
    end

    FinalDwellsValidated.PhageFile     = PhageFileName; %file name
    FinalDwellsValidated.FeedbackCycle = FeedbackCycle; %trace ID
    FinalDwellsValidated.Bandwidth     = Bandwidth; %bandwidth
%    FinalDwellsValidated.RawCont       = RawY;
%    FinalDwellsValidated.RawTime       = RawT;
    FinalDwellsValidated.FiltTime      = FiltT;
    FinalDwellsValidated.FiltCont      = FiltY;
    FinalDwellsValidated.FiltForce     = FiltF;
end