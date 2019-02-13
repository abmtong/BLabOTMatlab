function [Slips Pauses SlipPauseFreeSegments] = CalculateVelocity_RemoveSlipsPauses(Data,MinPauseDur,MinSlipSize)
% A slip will automatically break up a feedback cycle into two segments. If there is a pause, the
% pause is removed and it breaks up the trace into two segments. This function also will annotate
% the pause and slip information and properties.
% 
% Data.Dwells.StartInd(d)
% Data.Dwells.FinishInd(d)
% Data.Dwells.StartTime(d)
% Data.Dwells.FinishTime(d)
% Data.Dwells.DwellTime(d)
% Data.Dwells.MeanContour(d)
% Data.Dwells.MeanForce(d)
% Data.Dwells.StepAfter(d) in bp, StepAfter(end) = NaN;
%
% This function will create the following data structures/fields
% Slips.SlipStartLocation(s) 
% Slips.SlipFinishLocation(s)
% Slips.SlipStartTime(s)     
% Slips.SlipFinishTime(s)    
% Slips.SlipSize(s)          
%
% Pauses.PauseStartTime(p)  
% Pauses.PauseFinishTime(p) 
% Pauses.PauseLocation(p)   in terms of contour length, bp
% Pauses.PauseDuration(p)   in seconds
%
% SlipPauseFreeSegments.StartTime
% SlipPauseFreeSegments.FinishTime
%
% USE: [Slips Pauses SlipPauseFreeSegments] = CalculateVelocity_RemoveSlipsPauses(Data,MinPauseDur,MinSlipSize)
%
% Gheorghe Chistol, 29 Feb 2012

    %% Locate Valid Slips 
    Slips.SlipStartLocation  = [];
    Slips.SlipFinishLocation = [];
    Slips.SlipStartTime      = [];
    Slips.SlipFinishTime     = [];
    Slips.SlipSize           = [];
    
    SlipInd = find(Data.Dwells.StepAfter < -MinSlipSize); %the index of the dwell after which the slip occured
    
    for s = 1:length(SlipInd)
        CurrDwell                    = SlipInd(s); %the index of the dwell after which the current slip occured
        Slips.SlipStartLocation(s)   = Data.Dwells.MeanContour(CurrDwell);
        Slips.SlipFinishLocation(s)  = Data.Dwells.MeanContour(CurrDwell+1);
        Slips.SlipStartTime(s)       = Data.Dwells.FinishTime(CurrDwell);
        Slips.SlipFinishTime(s)      = Data.Dwells.StartTime(CurrDwell+1);
        Slips.SlipSize(s)            = -Data.Dwells.StepAfter(CurrDwell); %normal steps are positive, slips are negative steps, SlipSize is positive
    end
    
    %% Locate Valid Pauses
    Pauses.PauseStartTime  = [];
    Pauses.PauseFinishTime = [];
    Pauses.PauseLocation   = [];
    Pauses.PauseDuration   = [];
    
    PauseInd = find(Data.Dwells.DwellTime > MinPauseDur); %dwells that are too long are in fact pauses
    for p = 1:length(PauseInd)
        CurrDwell                 = PauseInd(p); %the index of the dwell that represents the current pause
        Pauses.PauseStartTime(p)  = Data.Dwells.StartTime(CurrDwell);
        Pauses.PauseFinishTime(p) = Data.Dwells.FinishTime(CurrDwell);
        Pauses.PauseLocation(p)   = Data.Dwells.MeanContour(CurrDwell);
        Pauses.PauseDuration(p)   = Data.Dwells.DwellTime(CurrDwell);
    end
    
    %% Split Trace into Pause and Slip Free Segments
    %If no slips/pauses, SlipPauseFreeSegment starts and ends where the raw data starts and ends
    SlipPauseFreeSegments.StartTime  = Data.Time(1);
    SlipPauseFreeSegments.FinishTime = Data.Time(end);
    
    %SlipPauseFreeSegment starts where a slip ends and finishes where a slip begins
    if ~isempty(Slips.SlipSize)
        SlipPauseFreeSegments.StartTime  = [SlipPauseFreeSegments.StartTime   Slips.SlipFinishTime];
        SlipPauseFreeSegments.FinishTime = [SlipPauseFreeSegments.FinishTime  Slips.SlipStartTime];
    end
    
    %SlipPauseFreeSegment starts where a pause ends and finishes where a pause starts
    if ~isempty(Pauses.PauseDuration)
        SlipPauseFreeSegments.StartTime  = [SlipPauseFreeSegments.StartTime   Pauses.PauseFinishTime];
        SlipPauseFreeSegments.FinishTime = [SlipPauseFreeSegments.FinishTime  Pauses.PauseStartTime];
    end
    
    %Sort the StartTime and FinishTime for SlipPauseFreeSegments
    SlipPauseFreeSegments.StartTime  = sort(SlipPauseFreeSegments.StartTime, 'ascend');
    SlipPauseFreeSegments.FinishTime = sort(SlipPauseFreeSegments.FinishTime,'ascend');
    
end