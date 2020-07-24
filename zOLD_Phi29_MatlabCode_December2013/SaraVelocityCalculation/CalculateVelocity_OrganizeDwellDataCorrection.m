function [Dwells LadderTime LadderContour LadderForce] = CalculateVelocity_OrganizeDwellDataCorrection(DwellInd,FiltTime,FiltForce,MinPauseDur,NumFrag)
% This function re-organizes the information about dwells in a more
% meaningful manner. It also creates LadderTime, LadderContour, and LadderForce which are convenient
% when wanting to plot stepping traces (which look like ladders)
%
% DwellInd(i).Start   index where dwell starts
% DwellInd(i).Finish  index where dwell ends
% DwellInd(i).Mean    the mean value (in contour length, bp) of the dwell
%
% Dwells.StartInd(d)
% Dwells.FinishInd(d)
% Dwells.StartTime(d)
% Dwells.FinishTime(d)
% Dwells.DwellTime(d)
% Dwells.MeanContour(d)
% Dwells.MeanForce(d)
% Dwells.StepAfter(d)      beware, Dwells.StepAfter(end) = NaN;
%
% USE: [Dwells LadderTime LadderContour LadderForce] = CalculateVelocity_OrganizeDwellData(DwellInd,FiltTime,FiltForce)
%
% Gheorghe Chistol, 29 Feb 2012

    Dwells.StartInd    = nan(1,length(DwellInd));
    Dwells.FinishInd   = nan(1,length(DwellInd));
    Dwells.StartTime   = nan(1,length(DwellInd));
    Dwells.FinishTime  = nan(1,length(DwellInd));
    Dwells.DwellTime   = nan(1,length(DwellInd));
    Dwells.MeanContour = nan(1,length(DwellInd));
    Dwells.MeanForce   = nan(1,length(DwellInd));
    Dwells.StepAfter   = nan(1,length(DwellInd));
    
    DeltaT = mean(diff(FiltTime)); %the spacing between time points
    LadderTime    = nan(1,2*length(DwellInd));
    LadderContour = nan(1,2*length(DwellInd));
    LadderForce   = nan(1,2*length(DwellInd));
    
    for d = 1:length(DwellInd)
        Dwells.StartInd(d)    = DwellInd(d).Start;
        Dwells.FinishInd(d)   = DwellInd(d).Finish;
        Dwells.StartTime(d)   = FiltTime(Dwells.StartInd(d));
        Dwells.FinishTime(d)  = FiltTime(Dwells.FinishInd(d));
        Dwells.DwellTime(d)   = (DwellInd(d).Finish - DwellInd(d).Start + 1)*DeltaT;
        Dwells.MeanContour(d) = DwellInd(d).Mean;
        Dwells.MeanForce(d)   = mean(FiltForce(Dwells.StartInd(d):Dwells.FinishInd(d)));
        
        LadderTime(   [2*d-1 2*d]) = [Dwells.StartTime(d) Dwells.FinishTime(d)];
        LadderContour([2*d-1 2*d]) = Dwells.MeanContour(d)*[1 1];
        LadderForce(  [2*d-1 2*d]) = Dwells.MeanForce(d)*[1 1];
        
        
        
    end
    
      % This section corrects for splitting the trace when the 
        if NumFrag>1
            offset=0;
            CorrTime(1)=LadderTime(1);
       
            for i=1:length(LadderTime)-1
                if (LadderTime(i)-LadderTime(i+1))> 7
                offset=offset+(LadderTime(i)-LadderTime(i+1))+(LadderTime(i-2)-LadderTime(i-1));
                end
            CorrTime(i+1)=LadderTime(i+1)+offset;
            %LadderContour(i+1)=Data.LadderContour(i+1);
            end
        %LadderTime(end)=LadderTime(end)+offset;
        LadderTime=CorrTime;
      
            for d=1:length(Dwells.DwellTime)
                Dwells.DwellTime(d)=LadderTime(2*d)-LadderTime(2*d-1);
                Dwells.StartTime(d)=LadderTime(2*d-1);
                Dwells.FinishTime(d)=LadderTime(2*d);
            end
        end
    
           
        
    for d = 1:length(DwellInd)-1
        Dwells.StepAfter(d) = Dwells.MeanContour(d)-Dwells.MeanContour(d+1);
    end
end