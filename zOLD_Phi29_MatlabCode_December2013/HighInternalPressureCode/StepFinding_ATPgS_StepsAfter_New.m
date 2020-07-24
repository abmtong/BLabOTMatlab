function StepFinding_ATPgS_StepsAfter_New()
    % This function is used to manually tag portions of the trace
    % immediately before an ATPgS-induced pause cluster. After this is
    % done, you can go ahead and validate the "high-res" ones, therefore
    % narrowing down the pool of Before-Portions for the final analysis.
    %
    % Gheorghe Chistol, 3 August 2011
    
    addpath([pwd filesep 'KalafutVisscher_StepFinding' filesep], '-end'); %where the KV scripts are located
    global analysisPath;
    [DataFile DataPath] = uigetfile([ [analysisPath filesep ] '*.mat'], 'Please select the Step Finding Results file','MultiSelect', 'on');
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
                        ClusterStartY = FinalDwells{ph}{fc}.DwellLocation(PauseClusters{ph}{fc}(c).DwellsInd(1));
                        ClusterStartT = FinalDwells{ph}{fc}.StartTime(PauseClusters{ph}{fc}(c).DwellsInd(1));
                        ClusterStopY  = FinalDwells{ph}{fc}.DwellLocation(PauseClusters{ph}{fc}(c).DwellsInd(end));
                        ClusterStopT  = FinalDwells{ph}{fc}.FinishTime(PauseClusters{ph}{fc}(c).DwellsInd(end));
                        FiltT = FinalDwells{ph}{fc}.FiltTime;
                        FiltY = FinalDwells{ph}{fc}.FiltCont;
                        RawT  = FinalDwells{ph}{fc}.RawTime;
                        RawY  = FinalDwells{ph}{fc}.RawCont;
                        
                        %Start at PauseClusters{ph}{fc}(c).DwellsInd(1) and move backward in time to find data within 30 bp
                        d = PauseClusters{ph}{fc}(c).DwellsInd(1);
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
                        d = PauseClusters{ph}{fc}(c).DwellsInd(end);
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
                        MainA = axes('Position',[0.1081 0.4477 0.6444 0.5046],'Box','on');
                        MainB = axes('Position',[0.7585 0.4462 0.2193 0.5062],'Box','on');

                        axes(MainA); hold on;
                        plot(RawT(RawInd),RawY(RawInd),    'Color',0.8*[1 1 1]);
                        plot(FiltT(FiltInd),FiltY(FiltInd),'Color',0.4*[1 1 1]);
                        x=[]; y=[];
                        for i=1:length(FinalDwells{ph}{fc}.DwellLocation)
                            x = [x FinalDwells{ph}{fc}.StartTime(i) FinalDwells{ph}{fc}.FinishTime(i) ];
                            y = [y FinalDwells{ph}{fc}.DwellLocation(i)*[1 1] ];
                        end
                        plot(x,y,'b','LineWidth',2);
                        XLim = [Tstart Tstop];
                        YLim = [min(RawY(RawInd)) max(RawY(RawInd))];
                        if sum(isnan([XLim YLim]))==0 
                            set(gca,'XLim',XLim); set(gca,'YLim',YLim);
                            x = [ClusterStartT*[1 1] ClusterStopT*[1 1]];
                            y = [YLim YLim([2 1])];
                            h=patch(x,y,'y'); set(h,'FaceAlpha',0.5,'LineStyle','none')
                        end
                        KernelFiltFact = 10; %ContrastThr = 1.5;
                        
                        % Plot the SideView Kernel Density for Entire Trace
                        ClusterInd = RawT>Cluster.Tstart & RawT<Cluster.Tstop;
                        temp = RawY(ClusterInd);
                        if sum(isnan(temp))==0
                            [Cluster.KernelX Cluster.KernelY] = KV_CalculateCustomKernelDensity(temp,KernelFiltFact);
                            axes(MainB); hold on
                            PlotInd = Cluster.KernelY > max(Cluster.KernelY)*0.01;
                            plot(Cluster.KernelX(PlotInd),Cluster.KernelY(PlotInd),'k','LineWidth',1.5);
                            camroll(90); set(gca,'XLim',YLim,'YLim',[0 1.1]);
                            set(gca,'XTick',[],'YTick',[])
                        end

                        %% Plot the Side Before Cluster
                        RawInd  = RawT>Before.Tstart  & RawT<Before.Tstop;
                        FiltInd = FiltT>Before.Tstart & FiltT<Before.Tstop;
                        BeforeA = axes('Position',[0.1093 0.0354 0.2730 0.3708],'Box','on');
                        BeforeB = axes('Position',[0.3852 0.0354 0.1259 0.3708],'Box','on');

                        axes(BeforeA); hold on;
                        plot(RawT(RawInd),RawY(RawInd),    'Color',0.8*[1 1 1]);
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
                        
                        % Plot the SideView Kernel Density for BeforeCluster
                        BeforeInd = RawT>Before.Tstart & RawT<Before.Tstop;
                        temp = RawY(BeforeInd);
                        if sum(isnan(temp))==0
                            [Before.KernelX Before.KernelY] = KV_CalculateCustomKernelDensity(temp,KernelFiltFact);
                            axes(BeforeB); hold on
                            PlotInd = Before.KernelY > max(Before.KernelY)*0.01;
                            area(Before.KernelX(PlotInd),Before.KernelY(PlotInd),'FaceColor','w','LineWidth',1);
                            camroll(90); set(gca,'XLim',YLim,'YLim',[0 1.1]);
                            set(gca,'XTick',[],'YTick',[])
                        end
                        
                        %% Plot the Side After Cluster
                        RawInd  = RawT>After.Tstart  & RawT<After.Tstop;
                        FiltInd = FiltT>After.Tstart & FiltT<After.Tstop;
                        AfterA = axes('Position',[0.5744 0.0354 0.2730 0.3708],'Box','on');
                        AfterB = axes('Position',[0.8519 0.0354 0.1259 0.3708],'Box','on');

                        axes(AfterA); hold on;
                        plot(RawT(RawInd),RawY(RawInd),    'Color',0.8*[1 1 1]);
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
                        
                        % Plot the SideView Kernel Density for AfterCluster
                        AfterInd = RawT>After.Tstart & RawT<After.Tstop;
                        temp = RawY(AfterInd);
                        if sum(isnan(temp))==0
                            [After.KernelX After.KernelY] = KV_CalculateCustomKernelDensity(temp,KernelFiltFact);
                            axes(AfterB); hold on
                            PlotInd = After.KernelY > max(After.KernelY)*0.01;
                            %plot(After.KernelX(PlotInd),After.KernelY(PlotInd),'k','LineWidth',1.5);
                            area(After.KernelX(PlotInd),After.KernelY(PlotInd),'FaceColor',rgb('LightGreen'),'LineWidth',1);
                            camroll(90); set(gca,'XLim',YLim,'YLim',[0 1.1]);
                            set(gca,'XTick',[],'YTick',[])
                        end
                        
                        reply = input('Is this After portion good? [a]: ', 's');
                        if strcmp(reply,'a')
                            PauseClusters{ph}{fc}(c).AfterIsGood = 1;
                            PauseClusters{ph}{fc}(c).AfterData   = After;
                            
                            SaveFolder = [analysisPath filesep 'AfterCensus'];
                            if ~isdir([analysisPath filesep 'AfterCensus'])
                                mkdir(SaveFolder);
                            end
                            temp = find((FinalDwells{ph}{fc}.PhageFile==filesep)==1,1,'Last');
                            SaveFile = [FinalDwells{ph}{fc}.PhageFile(temp+1:end-4) '_fc' num2str(FinalDwells{ph}{fc}.FeedbackCycle) '_c' num2str(c)];
                            axes(MainA); title(SaveFile,'Interpreter','none');
                            saveas(gcf,[SaveFolder filesep SaveFile],'png');
                            
                            Count = Count+1;
                            if rem(Count,10)==0
                                disp(['Reached ' num2str(Count) ' good after-pause count']);
                            end
                        else
                            PauseClusters{ph}{fc}(c).AfterIsGood = 0;
                            PauseClusters{ph}{fc}(c).AfterData   = [];
                        end
                        close(gcf);
                    end
                end
            end
        end
        save([DataPath filesep DataFile{df}(1:end-4) '_AfterExtra.mat'],'PauseClusters','FinalDwells');
    end
end