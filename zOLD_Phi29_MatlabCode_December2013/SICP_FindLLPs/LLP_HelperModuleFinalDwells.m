function [FinalDwells DwellInd] = LLP_HelperModuleFinalDwells(DwellInd,FiltT,FiltY,FiltF,PhageFileName,FeedbackCycle,Bandwidth)
% This function re-formats the results in a way that is consistent with
% our previous formatting from adaptive t-test calculations.
%
% The Kalafut-Visscher script generates the following data structure    
% DwellInd(d).Start  - dwell start  index in terms of FiltY
% DwellInd(d).Finish - dwell finish index in terms of FiltY
% DwellInd(d).Mean   
%
% The current function outputs the following
% DwellInd(d).Start
% DwellInd(d).Finish
% DwellInd(d).Mean  
% DwellInd(d).StartTime
% DwellInd(d).FinishTime
% DwellInd(d).DwellTime
% DwellInd(d).DwellLocation
%
%
% USE: [FinalDwells DwellInd] = LLP_HelperModuleFinalDwells(DwellInd,FiltT,FiltY,FiltF,PhageFileName,FeedbackCycle,Bandwidth)
%
% Gheorghe Chistol, 01 Dec 2012



    for d=1:length(DwellInd)
        ContData  = FiltY(DwellInd(d).Start:DwellInd(d).Finish); %contour data
        TimeData  = FiltT(DwellInd(d).Start:DwellInd(d).Finish); %time data
        ForceData = FiltF(DwellInd(d).Start:DwellInd(d).Finish); %force data
        
        DwellInd(d).StartTime     = FiltT(DwellInd(d).Start);
        DwellInd(d).FinishTime    = FiltT(DwellInd(d).Finish);
        DwellInd(d).DwellTime     = range(TimeData);
        DwellInd(d).DwellLocation = mean(ContData);
        DwellInd(d).DwellForce    = mean(ForceData);
        
        FinalDwells.Start(d)         = DwellInd(d).Start;
        FinalDwells.Finish(d)        = DwellInd(d).Finish;
        FinalDwells.StartTime(d)     = DwellInd(d).StartTime; %#ok<*AGROW>
        FinalDwells.FinishTime(d)    = DwellInd(d).FinishTime;
        FinalDwells.DwellTime(d)     = DwellInd(d).DwellTime;
        FinalDwells.DwellLocation(d) = DwellInd(d).DwellLocation;
        FinalDwells.DwellForce(d)    = DwellInd(d).DwellForce;
    end

    for d=1:length(DwellInd) %we can't calculate the step-size after the last dwell
        if d==length(DwellInd)
            FinalDwells.StepSize(d)     = NaN; %there is no step after the last dwell
            FinalDwells.StepLocation(d) = NaN;
            FinalDwells.StepForce(d)    = NaN;
        else
            FinalDwells.StepSize(d)     = DwellInd(d+1).DwellLocation - DwellInd(d).DwellLocation;
            FinalDwells.StepLocation(d) = mean([DwellInd(d+1).DwellLocation DwellInd(d).DwellLocation]); %where along DNA did this step occur?
            FinalDwells.StepForce(d)    = mean([DwellInd(d+1).DwellForce    DwellInd(d).DwellForce   ]); %where along DNA did this step occur?
        end    
    end

    %save this to the final data structure
    FinalDwells.PhageFile     = PhageFileName; %file name
    FinalDwells.FeedbackCycle = FeedbackCycle; %trace ID
    FinalDwells.Bandwidth     = Bandwidth; %bandwidth
    %FinalDwells.FiltCont      = FiltY;
    %FinalDwells.FiltTime      = FiltT;
    %FinalDwells.FiltTime      = FiltF;
end