function StepFinding_DetectATPgSClusters_ValidateEachCluster()
    % This function uses previously calculated PauseClusters (from
    % StepFinding_DetectATPgSClusters_Main). It displays a pause cluster
    % and asks for visual validation (Yes or no). In order for a pause
    % cluster to be valid it has to be preceded and followed by ~20-30bp of
    % normal packaging and it has to be clean) no weird hopping.
    % Unfortunately we can't automate this process so validation has to be
    % done by eye :)
    %
    %
    % Gheorghe Chistol, 26 July 2011
    
    addpath([pwd filesep 'KalafutVisscher_StepFinding' filesep], '-end'); %where the KV scripts are located
    global analysisPath;
    [DataFile DataPath] = uigetfile([ analysisPath filesep '*DetectATPgSClusters_Main.mat'], 'Please select the Results file','MultiSelect', 'on');
    if ~iscell(DataFile)
        temp=DataFile; clear DataFile; DataFile{1} = temp;
    end
    Count = 0;
    
    %load one file at a time
    for df=1:length(DataFile)
        clear PauseClusters FinalDwells;
        load([DataPath filesep DataFile{df}]);

        %go through all the elements of PauseClusters{phage}{feedbackcycle}
        for ph=1:length(PauseClusters) %ph is the PhageFile index
            for fc=1:length(PauseClusters{ph}) %fc is the FeedbackCycle index
                if ~isempty(PauseClusters{ph}{fc})
                    for c=1:length(PauseClusters{ph}{fc}) %c is the Cluster index
                        %Determine the start of the PauseCluster
                        ClusterStartY = FinalDwells{ph}{fc}.DwellLocation(PauseClusters{ph}{fc}(c).StartDwellInd);
                        ClusterStartT = FinalDwells{ph}{fc}.StartTime(PauseClusters{ph}{fc}(c).StartDwellInd);
                        ClusterStopY  = FinalDwells{ph}{fc}.DwellLocation(PauseClusters{ph}{fc}(c).FinishDwellInd);
                        ClusterStopT  = FinalDwells{ph}{fc}.FinishTime(PauseClusters{ph}{fc}(c).FinishDwellInd);
                        FiltT = FinalDwells{ph}{fc}.FiltTime;
                        FiltY = FinalDwells{ph}{fc}.FiltCont;
                        RawT  = FinalDwells{ph}{fc}.RawTime;
                        RawY  = FinalDwells{ph}{fc}.RawCont;
                        
                        %Start at PauseClusters{ph}{fc}(c).DwellsInd(1) and move backward in time to find data within 30 bp
                        d = PauseClusters{ph}{fc}(c).StartDwellInd;
                        Status = 1;
                        while Status
                            if FinalDwells{ph}{fc}.DwellLocation(d)<(ClusterStartY+30) && d>1 && FinalDwells{ph}{fc}.StepSize(d)<0
                                %we only continue if the step-size is negative (i.e. good translocation, not a slip)
                                d = d-1;
                            else
                                Status = 0;
                            end
                        end
                        Tstart = FinalDwells{ph}{fc}.StartTime(d);
                        
                        %Start at PauseClusters{ph}{fc}(c).DwellsInd(end) and move forward in time to find data within 30 bp
                        d = PauseClusters{ph}{fc}(c).FinishDwellInd;
                        Status = 1;
                        while Status
                            if FinalDwells{ph}{fc}.DwellLocation(d)>ClusterStopY-30 && d<length(FinalDwells{ph}{fc}.DwellLocation) && FinalDwells{ph}{fc}.StepSize(d)<0
                                %we only continue if the step-size is negative (i.e. good translocation, not a slip)
                                d = d+1; 
                            else
                                Status = 0;
                            end
                        end
                        Tstop = FinalDwells{ph}{fc}.FinishTime(d);
                        
                        Before.Tstart  = Tstart;               %this will help us find the StepSize right before the Cluster
                        Before.Tstop   = ClusterStartT + 0.5;  %this will help us find the StepSize right before the Cluster
                        After.Tstart   = ClusterStopT  - 0.5;  %this will help us find the StepSize right after the Cluster
                        After.Tstop    = Tstop;                %this will help us find the StepSize right after the Cluster 
                        Cluster.Tstart = ClusterStartT;
                        Cluster.Tstop  = ClusterStopT;
                        
                        %% Plot the Entire Trace
                        figure('Units','normalized','Position',[0.0029    0.0625    0.4941    0.8451]); 
                        RawInd  = RawT>Tstart  & RawT<Tstop;
                        FiltInd = FiltT>Tstart & FiltT<Tstop;
                        MainA = axes('Position',[0.1081    0.4477    0.8549    0.5046],'Box','on');

                        axes(MainA); hold on;
                        %plot(RawT(RawInd),RawY(RawInd),    'Color',0.8*[1 1 1]);
                        plot(FiltT(FiltInd),FiltY(FiltInd),'Color',0.5*[1 1 1]);
                        x=[]; y=[];
                        for i=1:length(FinalDwells{ph}{fc}.DwellLocation)
                            x = [x FinalDwells{ph}{fc}.StartTime(i) FinalDwells{ph}{fc}.FinishTime(i) ];
                            y = [y FinalDwells{ph}{fc}.DwellLocation(i)*[1 1] ];
                        end
                        plot(x,y,'b','LineWidth',1.5);
                        XLim = [Tstart Tstop];
                        YLim = [min(RawY(RawInd)) max(RawY(RawInd))];
                        if sum(isnan([XLim YLim]))==0 
                            set(gca,'XLim',XLim); set(gca,'YLim',YLim);
                            x = [ClusterStartT*[1 1] ClusterStopT*[1 1]];
                            y = [YLim YLim([2 1])];
                            h=patch(x,y,'y'); set(h,'FaceAlpha',0.5,'LineStyle','none')
                        end
                        

                        %% Plot the Side Before Cluster
                        RawInd  = RawT>Before.Tstart  & RawT<Before.Tstop;
                        FiltInd = FiltT>Before.Tstart & FiltT<Before.Tstop;
                        BeforeA = axes('Position',[0.1093    0.0354    0.4092    0.3708],'Box','on');

                        axes(BeforeA); hold on;
                        %plot(RawT(RawInd),RawY(RawInd),    'Color',0.8*[1 1 1]);
                        plot(FiltT(FiltInd),FiltY(FiltInd),'Color',0.4*[1 1 1]);
                        x=[]; y=[];
                        for i=1:length(FinalDwells{ph}{fc}.DwellLocation)
                            x = [x FinalDwells{ph}{fc}.StartTime(i) FinalDwells{ph}{fc}.FinishTime(i) ];
                            y = [y FinalDwells{ph}{fc}.DwellLocation(i)*[1 1] ];
                        end
                        plot(x,y,'b','LineWidth',2);
                        XLim = [Before.Tstart Before.Tstop];
                        YLim = [min(RawY(RawInd)) max(RawY(RawInd))];
                        if sum(isnan([XLim YLim]))==0 
                            set(gca,'XLim',XLim); set(gca,'YLim',YLim);
                            x = [ClusterStartT*[1 1] ClusterStopT*[1 1]];
                            y = [YLim YLim([2 1])];
                            h=patch(x,y,'y'); set(h,'FaceAlpha',0.5,'LineStyle','none')
                        end
                        
                        %% Plot the Side After Cluster
                        RawInd  = RawT>After.Tstart  & RawT<After.Tstop;
                        FiltInd = FiltT>After.Tstart & FiltT<After.Tstop;
                        AfterA = axes('Position',[0.5744    0.0354    0.3856    0.3708],'Box','on');

                        axes(AfterA); hold on;
                        %plot(RawT(RawInd),RawY(RawInd),    'Color',0.8*[1 1 1]);
                        plot(FiltT(FiltInd),FiltY(FiltInd),'Color',0.4*[1 1 1]);
                        x=[]; y=[];
                        for i=1:length(FinalDwells{ph}{fc}.DwellLocation)
                            x = [x FinalDwells{ph}{fc}.StartTime(i) FinalDwells{ph}{fc}.FinishTime(i) ];
                            y = [y FinalDwells{ph}{fc}.DwellLocation(i)*[1 1] ];
                        end
                        plot(x,y,'b','LineWidth',2);
                        XLim = [After.Tstart      After.Tstop];
                        YLim = [min(RawY(RawInd)) max(RawY(RawInd))];
                        if sum(isnan([XLim YLim]))==0 
                            set(gca,'XLim',XLim); set(gca,'YLim',YLim);
                            x = [ClusterStartT*[1 1] ClusterStopT*[1 1]];
                            y = [YLim YLim([2 1])];
                            h=patch(x,y,'y'); set(h,'FaceAlpha',0.5,'LineStyle','none')
                        end
                        
                        
                        reply = input('Is this a valid Pause Cluster? [y]: ', 's');
                        if strcmp(reply,'y')
                            PauseClusters{ph}{fc}(c).IsValid = 1;
                            
                            SaveFolder = [analysisPath filesep 'ClusterValidation'];
                            if ~isdir(SaveFolder)
                                mkdir(SaveFolder);
                            end
                            temp = find((FinalDwells{ph}{fc}.PhageFile==filesep)==1,1,'Last');
                            SaveFile = [FinalDwells{ph}{fc}.PhageFile(temp+1:end-4) '_fc' num2str(FinalDwells{ph}{fc}.FeedbackCycle) '_c' num2str(c)];
                            axes(MainA); 
                            title(SaveFile,'Interpreter','none');
                            saveas(gcf,[SaveFolder filesep SaveFile],'png');
                            
                            Count = Count+1;
                            if rem(Count,10)==0
                                disp(['Accumulated ' num2str(Count) ' good pause clusters']);
                            end
                        else
                            PauseClusters{ph}{fc}(c).IsValid = 0;
                        end
                        close(gcf);
                    end
                end
            end
        end
        save([DataPath filesep DataFile{df}(1:end-4) '_ValidatedClusters.mat'],'PauseClusters','FinalDwells');
    end
end