function z_TagBeforeRegions21Oct2011()
    % We're trying to see what the burst size is before a pause cluster
    % with a non-zero span. We have pre-tagged the good clusters with the
    % "ConsiderForSpecialSubunitAnalysis"
    %
    %             PauseClusters{29}{4}(2)
    %                                 StartDwellInd: 10
    %                                FinishDwellInd: 11
    %                                   ClusterSpan: 11.4395
    %                               ClusterDuration: 1.4160
    %                                       IsValid: 1
    %             ConsiderForSpecialSubunitAnalysis: 1
    %
    % Gheorghe Chistol, 21 October 2011
    
    addpath([pwd filesep 'KalafutVisscher_StepFinding' filesep], '-end'); %where the KV scripts are located
    global analysisPath;
    [File Path] = uigetfile([ analysisPath filesep  '*_SpecialSubunitAnalysis.mat'], 'Please select the Step Finding Results file','MultiSelect', 'off');
    load([Path filesep File]);
    
    Count = 0;
    KernelX = 0:0.1:30;
    KernelY = 0*KernelX;
    %load one file at a time

        %go through all the elements of PauseClusters{phage}{feedbackcycle}
        for ph=1:length(PauseClusters) %ph is the PhageFile index
            for fc=1:length(PauseClusters{ph}) %fc is the FeedbackCycle index
                if ~isempty(PauseClusters{ph}{fc})
                    for c=1:length(PauseClusters{ph}{fc}) %c is the Cluster index
                        if isfield(PauseClusters{ph}{fc}(c),'ConsiderForSpecialSubunitAnalysis')
                            if PauseClusters{ph}{fc}(c).ConsiderForSpecialSubunitAnalysis
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
                        
                                % Plot the Entire Trace
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
                                KernelFiltFact = 10; ContrastThr = 1.5;

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

                                % Plot the Side Before Cluster
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
                                    area(Before.KernelX(PlotInd),Before.KernelY(PlotInd),'FaceColor',rgb('LightGreen'),'LineWidth',1);
                                    camroll(90); set(gca,'XLim',YLim,'YLim',[0 1.1]);
                                    set(gca,'XTick',[],'YTick',[])
                                end
                        
                                % Plot the Side After Cluster
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
                        
                                % Plot the SideView Kernel Density for BeforeCluster
                                AfterInd = RawT>After.Tstart & RawT<After.Tstop;
                                temp = RawY(AfterInd);
                                if sum(isnan(temp))==0
                                    [After.KernelX After.KernelY] = KV_CalculateCustomKernelDensity(temp,KernelFiltFact);
                                    axes(AfterB); hold on
                                    PlotInd = After.KernelY > max(After.KernelY)*0.01;
                                    plot(After.KernelX(PlotInd),After.KernelY(PlotInd),'k','LineWidth',1.5);
                                    camroll(90); set(gca,'XLim',YLim,'YLim',[0 1.1]);
                                    set(gca,'XTick',[],'YTick',[])
                                end
                                
                                % Ask if this is a good cluster for the purpose of our analysis1
                                Response = questdlg('Is the before portion good?', 'Cluster "Before" Selection','Yes','No','No');
                                % Handle response
                                if strcmp(Response,'Yes')
                                    PauseClusters{ph}{fc}(c).BeforeIsGood = 1;
                                    PauseClusters{ph}{fc}(c).BeforeData   = Before;
                            
                                    SaveFolder = [analysisPath filesep 'SpecialBeforeStepCensus'];
                                    if ~isdir(SaveFolder)
                                        mkdir(SaveFolder);
                                    end
                                    temp = find((FinalDwells{ph}{fc}.PhageFile==filesep)==1,1,'Last');
                                    SaveFile = [FinalDwells{ph}{fc}.PhageFile(temp+1:end-4) '_fc' num2str(FinalDwells{ph}{fc}.FeedbackCycle) '_c' num2str(c)];
                                    axes(MainA); title(SaveFile,'Interpreter','none');
                                    saveas(gcf,[SaveFolder filesep SaveFile],'png');

                                    % Add the current Kernel Density to the cumulative KernelDensity
                                    if sum(isnan(Before.KernelY))==0 && ~isempty(Before.KernelY)
                                        %find the offset
                                        OffsetInd = []; i=2;
                                        while i<length(Before.KernelY)
                                            if Before.KernelY(i+1)<Before.KernelY(i) && Before.KernelY(i-1)<Before.KernelY(i)
                                                %we got the first local maxima
                                                OffsetInd = i; i=NaN;
                                            end
                                            i=i+1;
                                        end
                                        if ~isempty(OffsetInd)
                                            axes(BeforeB); hold on;
                                            plot(Before.KernelX(OffsetInd),Before.KernelY(OffsetInd),'bo');
                                            OffsetVal = Before.KernelX(OffsetInd);
                                            temp = interp1(Before.KernelX-OffsetVal,Before.KernelY,KernelX,'linear',0);
                                            %figure; plot(KernelX,temp,'b');
                                            %pause(1); close(gcf);
                                            KernelY = KernelY+temp;
                                        end
                                    end
                            
                                    Count = Count+1;
                                    if rem(Count,10)==0
                                        disp(['Reached ' num2str(Count) ' good Before pause count']);
                                        figure('Units','normalized','Position',[0.1603 0.3828 0.2284 0.2695]);
                                        area(KernelX,KernelY,'FaceColor','m','LineWidth',1);
                                        pause(1); close(gcf);
                                    end
                            else
                                PauseClusters{ph}{fc}(c).BeforeIsGood = 0;
                                PauseClusters{ph}{fc}(c).BeforeData   = [];
                            end
                        close(gcf);
                    end
                end
            end
        end
    end
end
        
save([Path filesep File(1:end-4) '_Before.mat'],'PauseClusters','FinalDwells');
figure('Units','normalized','Position',[0.1603 0.3828 0.2284 0.2695]);
area(KernelX,KernelY,'FaceColor','m','LineWidth',1);
xlabel('Distance from Cluster Beginning (bp)');
ylabel('Occupancy');

end %end of the current function