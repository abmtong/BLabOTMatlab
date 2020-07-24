function PauseClusters = KV_ATPgS_IdentifyPauseClusters2(FinalDwells,FigureH,MaxSeparation,MinPauseDuration)
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
    LongDwellsLocation= [];
    LongDwellsStart= [];
    LongDwellsEnd= [];
    LongDwellInd = [];
    PauseClusterStart=[];
    PauseClusterEnd=[];
    PauseClusters.Start=[];
    PauseClusters.End=[];
    PauseClusterSpan=[];
    LongDwellDuration = [];

    if isempty(FinalDwells)
        return;
    end
    
    % Goes through every single dwell and checks if this is a pause
    % depending on this threshold MinPauseDuration
    
    for CurrDwell=1:length(FinalDwells.DwellLocation)
        if FinalDwells.DwellTime(CurrDwell)>MinPauseDuration
            LongDwellInd=[LongDwellInd CurrDwell];
            LongDwellsLocation=[LongDwellsLocation FinalDwells.DwellLocation(CurrDwell)];
            LongDwellsStart=[LongDwellsStart FinalDwells.StartTime(CurrDwell)];
            LongDwellsEnd=[LongDwellsEnd FinalDwells.FinishTime(CurrDwell)];     
            LongDwellDuration=[LongDwellDuration FinalDwells.FinishTime(CurrDwell)-FinalDwells.StartTime(CurrDwell)];

        end 
    end
    
    %We are starting Cluster Variables.
    
    ClusterStart=0;
    ClusterEnd=0;
    Isthisfirst=0;
    
    
    if ~isempty(LongDwellsLocation)
    LastPauseLocation=LongDwellsLocation(1);
    LastPauseIndex=LongDwellInd(1)
    end
    
    % Goes through every pause to check if this is a pause or a
    % pause-cluster
    for CurrPause=1:length(LongDwellsLocation)
        DistanceCurrentPause=LongDwellsLocation - LongDwellsLocation(CurrPause);
        PauseIndexForCluster=find( abs(DistanceCurrentPause)>0 & abs(DistanceCurrentPause)<MaxSeparation );
        TempStart=LongDwellsStart(CurrPause);
        TempEnd=LongDwellsEnd(CurrPause);
        
         %Checks if previous dwell, even though short, from current pause is part of the same Pause
                if LongDwellInd(CurrPause)-1 > 1
                    if abs(FinalDwells.DwellLocation(LongDwellInd(CurrPause)-1)-FinalDwells.DwellLocation(LongDwellInd(CurrPause)))< MaxSeparation/2
                        TempStart=FinalDwells.StartTime(LongDwellInd(CurrPause)-1);
                    end
                end
                
        if ~isempty(PauseIndexForCluster) %Checks if here are nearby pauses
            
            %In case we enter a pause cluster right after another one the
            %next condition checks that the last PauseLocation was further
            %away
            
            if abs(LastPauseLocation-LongDwellsLocation(CurrPause))>2*MaxSeparation && Isthisfirst>1
                % if true, we just exited a previous pause... However we
                % need to close the previous pause cluster, so we check if check if following dwell 
                %from previous past is part of the same previous pause
                
                if LastPauseIndex+1<length(FinalDwells.DwellLocation)
                    if abs(FinalDwells.DwellLocation(LastPauseIndex+1)-FinalDwells.DwellLocation(LastPauseIndex))< MaxSeparation/2
                        ClusterEnd=FinalDwells.FinishTime(LastPauseIndex+1);
                    end
                end
               %It writes the previous pause cluster and colors it yellow
               %in the graph 
               PauseClusterStart=[PauseClusterStart ClusterStart];
               PauseClusterEnd=[PauseClusterEnd ClusterEnd];
               
             
               
               figure(FigureH); %select the current figure
               YLim = get(gca,'YLim'); set(gca,'YLim',YLim);
               X = [ClusterStart*[1 1] ClusterEnd(end)*[1 1]];
               Y = [min(YLim) max(YLim)*[1 1] min(YLim)];
               PatchH = patch(X,Y,'y'); set(PatchH,'EdgeColor','none','FaceAlpha',0.4); 
               
               %resets the values for next pause cluster
               ClusterStart=0;
               ClusterEnd=0;
               Isthisfirst=0;
               
            end
            
            %In case this is part of the same cluster, we are within the cluster, it will redefine the
            %limits of the cluster 
    
            if(ClusterStart==0 || TempStart<ClusterStart)
                disp('Redefined Start')
                ClusterStart=TempStart;
                Isthisfirst=Isthisfirst+1;
            end   
           
            if(ClusterEnd==0 || TempEnd>ClusterEnd)
                disp('Redefined End')
                ClusterEnd=TempEnd;
                Isthisfirst=Isthisfirst+1;
            end
            
            %In case this is the last pause in the trace and happens to be
            %in a cluster we want to close it
            if CurrPause==length(LongDwellsLocation) 
                %Check if following dwell is part of the same Pause
                
                if LongDwellInd(CurrPause)+1<length(FinalDwells.DwellLocation)
                    disp('Entered here')
                    if abs(FinalDwells.DwellLocation(LongDwellInd(CurrPause)+1)-FinalDwells.DwellLocation(LongDwellInd(CurrPause)))< MaxSeparation/2
                        ClusterEnd=FinalDwells.FinishTime(LongDwellInd(CurrPause)+1);
                    end
                end
                
               %disp we just exited the final cluster of the trace, so we
               %write down the cluster and plot it
               disp('We are writing the last pause cluster')
               PauseClusterStart=[PauseClusterStart ClusterStart];
               PauseClusterEnd=[PauseClusterEnd ClusterEnd];
              
               figure(FigureH); %select the current figure
               YLim = get(gca,'YLim'); set(gca,'YLim',YLim);
     
               X = [ClusterStart*[1 1] ClusterEnd(end)*[1 1]];
               Y = [min(YLim) max(YLim)*[1 1] min(YLim)];
               PatchH = patch(X,Y,'y'); set(PatchH,'EdgeColor','none','FaceAlpha',0.4);  
               
               %Redefine the paramaters for next file
                ClusterStart=0;
                ClusterEnd=0;
                Isthisfirst=0;
            end 
            
        else
            %If entered here that meand there were no nearby pauses. We
            %either exited a pause cluster or we are coming from a single
            %pause.
            
            %Checks we are coming out from a cluster
            if(ClusterStart~=0 && ClusterEnd~=0 && Isthisfirst>1)
                %If true, it checks if following dwell from previous pause
                %is part of the same pause to close the cluster
                
                if LastPauseIndex+1<length(FinalDwells.DwellLocation)
                    disp('After finishing Cluster check for next dwell')
                    if abs(FinalDwells.DwellLocation(LastPauseIndex+1)-FinalDwells.DwellLocation(LastPauseIndex))< MaxSeparation/2
                        disp('Redefines end of cluster')
                        ClusterEnd=FinalDwells.FinishTime(LastPauseIndex+1);
                    end
                end
                
                % so we exited the pause and now we write and plot it.
                PauseClusterStart=[PauseClusterStart ClusterStart];
                PauseClusterEnd=[PauseClusterEnd ClusterEnd];
             
                disp('We just exited a cluster in the previous pause and we are writing it');
                
                figure(FigureH); %select the current figure
                YLim = get(gca,'YLim'); set(gca,'YLim',YLim);
     
                X = [ClusterStart*[1 1] ClusterEnd(end)*[1 1]];
                Y = [min(YLim) max(YLim)*[1 1] min(YLim)];
                PatchH = patch(X,Y,'y'); set(PatchH,'EdgeColor','none','FaceAlpha',0.4);
                 
                ClusterStart=0;
                ClusterEnd=0;
                Isthisfirst=0;
                %disp('entered here to write cluster')
                
            end
                disp('We are now writing this pause')
                
                
                %Check if previous dwell is part of the same Pause
                if LongDwellInd(CurrPause)-1>1
                    if abs(FinalDwells.DwellLocation(LongDwellInd(CurrPause)-1)-FinalDwells.DwellLocation(LongDwellInd(CurrPause)))< MaxSeparation/2
                        TempStart=FinalDwells.StartTime(LongDwellInd(CurrPause)-1);
                    end
                end
                
                %Check if following dwell is part of the same Pause
                
                if LongDwellInd(CurrPause)+1<length(FinalDwells.DwellLocation)
                    disp('We are looking at the dwell after this pause')
                    if abs(FinalDwells.DwellLocation(LongDwellInd(CurrPause)+1)-FinalDwells.DwellLocation(LongDwellInd(CurrPause)))< MaxSeparation/2
                        TempEnd=FinalDwells.FinishTime(LongDwellInd(CurrPause)+1);
                        TempEnd
                        LongDwellInd(CurrPause)+1
                        disp('We are includign the enxt dwell')
                    end
                end
                
                PauseClusterStart=[PauseClusterStart TempStart];
                PauseClusterEnd=[PauseClusterEnd TempEnd];
                PauseClusterSpan=[PauseClusterSpan 0];
                
                ClusterStart=0;
                ClusterEnd=0;
                Isthisfirst=0;
                
                figure(FigureH); %select the current figure
                YLim = get(gca,'YLim'); set(gca,'YLim',YLim);
     
                X = [TempStart*[1 1] TempEnd(end)*[1 1]];
                Y = [min(YLim) max(YLim)*[1 1] min(YLim)];
                PatchH = patch(X,Y,'y'); set(PatchH,'EdgeColor','none','FaceAlpha',0.4);
           
        end
        LastPauseLocation=LongDwellsLocation(CurrPause);
        LastPauseIndex=LongDwellInd(CurrPause);
    end
    
   
    
    PauseClusters.NumberOfPauses=length(PauseClusterEnd);
    PauseClusters.TotalDNAContourLength=FinalDwells.DwellLocation(1)-FinalDwells.DwellLocation(end);
    PauseClusters.PauseDensity= PauseClusters.NumberOfPauses/(PauseClusters.TotalDNAContourLength/1000);
    PauseClusters.Start=PauseClusterStart;
    PauseClusters.End=PauseClusterEnd;
    PauseClusters.LongDwells=LongDwellsLocation;
    PauseClusters.LongDwellDuration=LongDwellDuration;
    
end