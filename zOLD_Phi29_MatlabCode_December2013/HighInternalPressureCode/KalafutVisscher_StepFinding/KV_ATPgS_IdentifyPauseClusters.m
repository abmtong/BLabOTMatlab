function PauseClusters = KV_ATPgS_IdentifyPauseClusters(FinalDwells,FigureH,MaxSeparation,MinPauseDuration)
    % 
    % USE: KV_ATPgS_IdentifyPauseClusters(FinalDwells,FigureH,MaxSeparation,MinPauseDuration)
    %
    % Gheorghe Chistol, 7 July 2011
    
    %             Start: [1 45 108 146 210 251 283 316 350 392 435 471 509 566]
    %            Finish: [44 107 145 209 250 282 315 349 391 434 470 508 565 598]
    %         StartTime: [1x14 double]
    %        FinishTime: [1x14 double]
    %         DwellTime: [1x14 double]
    %     DwellLocation: [1x14 single]
    %          StepSize: [1x14 single]
    %      StepLocation: [1x14 single]
    %         PhageFile: [1x107 char]
    %     FeedbackCycle: 14
    %         Bandwidth: 250
    %           RawCont: [1x5980 single]
    %           RawTime: [1x5980 double]
    %          FiltCont: [1x598 single]
    %          FiltTime: [1x598 double]

    PauseClusters          = [];
    IsInsideCluster        = 0;
    FirstLongPauseDwellInd = NaN;
    LastLongPauseDwellInd  = NaN;    
    LastLongPauseLocation  = NaN;
    LongPausesInCluster = [];
    LongDwellsLocation= [];
    LongDwellsStart= [];
    LongDwellsEnd= [];
    ClusterStart=NaN;
    ClusterEnd=NaN;
    LongDwellDuration = [];
    if isempty(FinalDwells)
        return;
    end
    
    for CurrDwell=1:length(FinalDwells.DwellLocation)
        
        if FinalDwells.DwellTime(CurrDwell)>MinPauseDuration
            LongDwellsLocation=[LongDwellsLocation FinalDwells.DwellLocation(CurrDwell)];
            LongDwellsStart=[LongDwellsStart FinalDwells.StartTime(CurrDwell)];
            LongDwellsEnd=[LongDwellsEnd FinalDwells.FinishTime(CurrDwell)];     
            LongDwellDuration=[LongDwellDuration FinalDwells.FinishTime(CurrDwell)-FinalDwells.StartTime(CurrDwell)];
            %we got a long pause, either the start of a new cluster or the
            %continuation of an existing cluster
            if IsInsideCluster == 0
                %clear LongPausesInCluster;
                %we just started a new cluster
                disp('Just Started a New Cluster');
                FirstLongPauseDwellInd = CurrDwell;
                LastLongPauseLocation  = FinalDwells.DwellLocation(CurrDwell);
                LastLongPauseDwellInd  = CurrDwell;
                ClusterStart           = FinalDwells.StartTime(CurrDwell);
                ClusterEnd             = FinalDwells.FinishTime(CurrDwell);  
                %LongPausesInClutser    = [LongPausesInCluster FinalDwells.DwellLocation(CurrDwell)];
                IsInsideCluster        = 1;
            else
                %we could be within an existing cluster, we could be past the end of an existing cluster
                %SeparationCondition = abs(FinalDwells.DwellLocation(CurrDwell)-LastLongPauseLocation) < MaxSeparation;
                if ~isempty(find(abs(LongDwellDuration-FinalDwells.DwellLocation(CurrDwell))<MaxSeparation)); %we are within an existing cluster
                    LastLongPauseLocation = FinalDwells.DwellLocation(CurrDwell);
                    LastLongPauseDwellInd = CurrDwell;
                    ClusterEnd=FinalDwells.FinishTime(CurrDwell);
                    disp('itEnteredHere.It is trying to ccomplete the cluster') 
                else %we just exited a pause cluster because it's too far
                    PauseClusters(end+1).DwellsInd = FirstLongPauseDwellInd:LastLongPauseDwellInd; %#ok<*AGROW>
                    IsInsideCluster        = 0;
                    FirstLongPauseDwellInd = NaN;
                    LastLongPauseDwellInd  = NaN; %#ok<*NASGU>
                    LastLongPauseLocation  = NaN;
                    LongPausesInCluster=[];
                    ClusterEnd=FinalDwells.FinishTime(CurrDwell);
                    disp('Just Finished a Cluster');
                end
            end
        else
            if IsInsideCluster == 1
                %look for a case where we just exited the pause cluster
                if isempty(find(abs(LongPausesInCluster-FinalDwells.DwellLocation(CurrDwell))<MaxSeparation));
                    %we just exited a pause cluster
                    PauseClusters(end+1).DwellsInd = FirstLongPauseDwellInd:LastLongPauseDwellInd; %#ok<*AGROW>
                    IsInsideCluster        = 0;
                    FirstLongPauseDwellInd = NaN;
                    LastLongPauseDwellInd  = NaN; %#ok<*NASGU>
                    LastLongPauseLocation  = NaN;
                    LongPausesInCluster=[];
                    ClusterEnd=FinalDwells.FinishTime(CurrDwell);
                    disp('Just Finished a Cluster');                    
                end
            end
        end
    end
    
   %if we're still in a pause cluster but we reached the end, "close" the pause cluster
   if IsInsideCluster==1
        LastLongPauseDwellInd          = CurrDwell;
        PauseClusters(end+1).DwellsInd = FirstLongPauseDwellInd:LastLongPauseDwellInd;
        ClusterEnd=FinalDwells.FinishTime(CurrDwell);
   end
    
    figure(FigureH); %select the current figure
    YLim = get(gca,'YLim'); set(gca,'YLim',YLim);
    
    %add more information about the pause clusters to the data structure
    if ~isempty(PauseClusters)
        for pc = 1:length(PauseClusters) %pc stands for "PauseCluster"
            ClusterDwells = PauseClusters(pc).DwellsInd;
           % PauseClusters(pc).ClusterDuration = FinalDwells.FinishTime(ClusterDwells(end))-FinalDwells.StartTime(ClusterDwells(1));
            PauseClusters(pc).ClusterDuration = ClusterEnd-ClusterStart;
           % PauseClusters(pc).ClusterSpan     = range(FinalDwells.DwellLocation(ClusterDwells)); %a single pause has a zero span
            [ValStart,IndStart]=min(abs(FinalDwells.StartTime-ClusterStart));
            [ValEnd,IndEnd]=min(abs(FinalDwells.FinishTime-ClusterEnd));
            PauseClusters(pc).Span=abs(FinalDwells.DwellLocation(IndStart)-FinalDwells.DwellLocation(IndEnd));         
            PauseClusters(pc).Location=FinalDwells.DwellLocation(IndStart);
            PauseClusters(pc).LongDwellLocation=LongDwellsLocation;
            PauseClusters(pc).LongDwellStart=LongDwellsStart;
            PauseClusters(pc).LongDwellEnd=LongDwellsEnd;
            PauseClusters(pc).Start=ClusterStart;
            PauseClusters(pc).End=ClusterEnd;
            
            X = [FinalDwells.StartTime(ClusterDwells(1))*[1 1] FinalDwells.FinishTime(ClusterDwells(end))*[1 1]];
            Y = [min(YLim) max(YLim)*[1 1] min(YLim)];
            PatchH = patch(X,Y,'y'); set(PatchH,'EdgeColor','none','FaceAlpha',0.4);
            
            if ClusterDwells(1)>1
                %we can determine the Step/Dwell before the PauseCluster
                PauseClusters(pc).StepBefore      = FinalDwells.DwellLocation(ClusterDwells(1)-1)-FinalDwells.DwellLocation(ClusterDwells(1));
                PauseClusters(pc).DwellTimeBefore = FinalDwells.DwellTime(ClusterDwells(1)-1);
            else
                PauseClusters(pc).StepBefore      = NaN;
                PauseClusters(pc).DwellTimeBefore = NaN;
            end
            
            if ClusterDwells(end)<length(FinalDwells.DwellLocation)
                %we can determine the Step/Dwell after the PauseCluster
                PauseClusters(pc).StepAfter      = FinalDwells.DwellLocation(ClusterDwells(end))-FinalDwells.DwellLocation(ClusterDwells(end)+1);
                PauseClusters(pc).DwellTimeAfter = FinalDwells.DwellTime(ClusterDwells(end)+1);
            else
                PauseClusters(pc).StepAfter      = NaN;
                PauseClusters(pc).DwellTimeAfter = NaN;
            end
            LongDwellsLocation =[];
            LongDwellsStart =[];
            LongDwellsEnd =[];
        end
         
    end
end