function LongDwells = SaraKV_ATPgS_FindLongDwells(FinalDwells,FigureH,MaxSeparation,MinPauseDuration)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    PauseClusters          = [];
    IsInsideCluster        = 0;
    FirstLongPauseDwellInd = NaN;
    LastLongPauseDwellInd  = NaN;    
    LastLongPauseLocation  = NaN;
    LongPausesInCluster = [];
    if isempty(FinalDwells)
        return;
    end
    
    
    for CurrDwell=1:length(FinalDwells.DwellLocation)
        if FinalDwells.DwellTime(CurrDwell)>MinPauseDuration
          LongDwells.Duration=FinalDwells.DwellTime(CurrDwell);
          LongDwells.Start=FinalDwells.Start(CurrDwell);
          LongDwells.Finish=FinalDwells.Finish(CurrDwell);
        end
    end   
    

end

