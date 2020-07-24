function StepFinding_KalafutVisscher_ATPgS_StepsBeforeAfter()
    % Load Existing Step-Finding results for ATPgS data and use validation
    % to determine step before/after
    %
    % Gheorghe Chistol, 12 July 2011
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
                        %if exist('ATPgS_ClusterData','var')
                        %    ATPgS_ClusterData(end+1)=PauseClusters{ph}{fc}(c);
                        %else
                        %    ATPgS_ClusterData(1)=PauseClusters{ph}{fc}(c);
                        %end
                        
                        %Determine the start of the PauseCluster
                        ClusterStartY  = FinalDwells{ph}{fc}.DwellLocation(PauseClusters{ph}{fc}(c).DwellsInd(1));
                        ClusterStartT  = FinalDwells{ph}{fc}.StartTime(PauseClusters{ph}{fc}(c).DwellsInd(1));
                        ClusterFinishY = FinalDwells{ph}{fc}.DwellLocation(PauseClusters{ph}{fc}(c).DwellsInd(end));
                        ClusterFinishT = FinalDwells{ph}{fc}.FinishTime(PauseClusters{ph}{fc}(c).DwellsInd(end));
                        FiltT = FinalDwells{ph}{fc}.FiltTime;
                        FiltY = FinalDwells{ph}{fc}.FiltCont;
                        RawT  = FinalDwells{ph}{fc}.RawTime;
                        RawY  = FinalDwells{ph}{fc}.RawCont;
                        
                        %Start at PauseClusters{ph}{fc}(c).DwellsInd(1) and move backward in time to find data within 30 bp
                        d = PauseClusters{ph}{fc}(c).DwellsInd(1);
                        Status = 1;
                        while Status
                            if FinalDwells{ph}{fc}.DwellLocation(d)<(ClusterStartY+20) && d>1
                                d = d-1;
                            else
                                Status = 0;
                            end
                        end
                        %d
                        Tstart = FinalDwells{ph}{fc}.StartTime(d);
                        
                        %Start at PauseClusters{ph}{fc}(c).DwellsInd(end) and move forward in time to find data within 30 bp
                        d = PauseClusters{ph}{fc}(c).DwellsInd(end);
                        Status = 1;
                        while Status
                            if FinalDwells{ph}{fc}.DwellLocation(d)>ClusterFinishY-20 && d<length(FinalDwells{ph}{fc}.DwellLocation)
                                d = d+1; 
                            else
                                Status = 0;
                            end
                        end
                       % d
                        Tstop = FinalDwells{ph}{fc}.FinishTime(d);
                       % Tstart
                      %  Tstop
                        
                        Before.Tstart = Tstart;             %this will help us find the StepSize right before the Cluster
                        Before.Tstop = ClusterStartT;  %this will help us find the StepSize right before the Cluster
                        After.Tstart = ClusterFinishT; %this will help us find the StepSize right after the Cluster
                        After.Tstop = Tstop;                %this will help us find the StepSize right after the Cluster 
                        Cluster.Tstart = ClusterStartT;
                        Cluster.Tstop  = ClusterFinishT;
                        
                        %return
                        RawInd  = RawT>Tstart  & RawT<Tstop;
                        FiltInd = FiltT>Tstart & FiltT<Tstop;
                        figure('Units','normalized','Position',[0.0029    0.0625    0.4941    0.8451]); 
                        %A1 = axes('Position',[0.0483    0.0426    0.7357    0.9361]);
                        %A2 = axes('Position',[0.7892    0.0426    0.1999    0.9361],'XTick',[],'YTick',[],'Box','on');
                        %axes(A1);
                        hold on;
                        tempRawT = RawT(RawInd); 
                        tempRawY = RawY(RawInd);
                        tempFiltT = FiltT(FiltInd);
                        tempFiltY = FiltY(FiltInd);
                        plot(tempRawT,  tempRawY,  'Color',0.8*[1 1 1]);
                        plot(tempFiltT, tempFiltY, 'Color',0.4*[1 1 1]);
%                         plot(RawT,  RawY,  'Color',0.8*[1 1 1]);
%                         plot(FiltT,FiltY,'Color',0.4*[1 1 1]);
                        x=[];
                        y=[];
                        for i=1:length(FinalDwells{ph}{fc}.DwellLocation)
                            x = [x FinalDwells{ph}{fc}.StartTime(i) FinalDwells{ph}{fc}.FinishTime(i) ];
                            y = [y FinalDwells{ph}{fc}.DwellLocation(i)*[1 1] ];
                        end
                        plot(x,y,'b','LineWidth',2);
                        XLim = [Tstart Tstop];
                        YLim = [min(tempRawY) max(tempRawY)];
                        if sum(isnan([XLim YLim]))==0 
                            set(gca,'XLim',XLim);
                            set(gca,'YLim',YLim);
                            x = [ClusterStartT*[1 1] ClusterFinishT*[1 1]];
                            y = [YLim YLim([2 1])];
                            h=patch(x,y,'y'); set(h,'FaceAlpha',0.5,'LineStyle','none')
                        end
                        KernelFiltFact = 50;
                        ContrastThr = 1.5;
%                         %% Calculate the Custom KD for the Cluster Only
%                         ClusterInd = RawT>Cluster.Tstart & RawT<Cluster.Tstop;
%                         [KernelGrid KernelValue] = KV_CalculateCustomKernelDensity(RawY(ClusterInd),KernelFiltFact);
%                         axes(A2); hold on
%                         PlotInd = KernelValue>max(KernelValue)*0.02;
%                         plot(KernelGrid(PlotInd),KernelValue(PlotInd),'y','LineWidth',1.5);
%                         camroll(90); set(gca,'XLim',YLim);
% %                        global LocalMaxima;
%                         LocalMaxima = KV_IdentifyLocalMaxima(KernelGrid, KernelValue, ContrastThr);
%                         for m=1:length(LocalMaxima.LocalMaxInd)
%                             if LocalMaxima.IsValid(m)
%                                 temp = LocalMaxima.LocalMaxInd(m);
%                                 plot(KernelGrid(temp),KernelValue(temp),'.b','MarkerSize',15);
%                                 temp = [LocalMaxima.LeftLocalMinInd(m) LocalMaxima.RightLocalMinInd(m)];
%                                 plot(KernelGrid(temp),KernelValue(temp),'.k','MarkerSize',15);
%                             end
%                         end
%                         
% %                        %Validated Dwells based on the Local Maxima
% %                        ValidatedFragDwellInd{f} = KV_ValidateDwells(tempFiltT, tempFiltY, tempDwellInd, LocalMaxima, MaxSeparation); %#ok<AGROW>
% 
%                         %% Calculate Custom KD for the StepBefore
%                         BeforeInd =  RawT>Before.Tstart & RawT<Before.Tstop;
%                         [KernelGrid KernelValue] = KV_CalculateCustomKernelDensity(RawY(BeforeInd),KernelFiltFact);
%                         PlotInd = KernelValue>max(KernelValue)*0.02;
%                         plot(KernelGrid(PlotInd),KernelValue(PlotInd),'r','LineWidth',1.5);                        
%                         LocalMaxima = KV_IdentifyLocalMaxima(KernelGrid, KernelValue, ContrastThr);
%                         for m=1:length(LocalMaxima.LocalMaxInd)
%                             if LocalMaxima.IsValid(m)
%                                 temp = LocalMaxima.LocalMaxInd(m);
%                                 plot(KernelGrid(temp)*[1 1],[0 KernelValue(temp)],'b');
%                                 %temp = [LocalMaxima.LeftLocalMinInd(m) LocalMaxima.RightLocalMinInd(m)];
%                                 %plot(KernelGrid(temp),KernelValue(temp),'.k','MarkerSize',15);
%                             end
%                         end
%                         
%                     
%                         %% Calculate Custom KD for the StepAfter
%                         AfterInd =  RawT>After.Tstart & RawT<After.Tstop;
%                         [KernelGrid KernelValue] = KV_CalculateCustomKernelDensity(RawY(AfterInd),KernelFiltFact);
%                         PlotInd = KernelValue>max(KernelValue)*0.02;
%                         plot(KernelGrid(PlotInd),KernelValue(PlotInd),'b','LineWidth',1.5);
%                         LocalMaxima = KV_IdentifyLocalMaxima(KernelGrid, KernelValue, ContrastThr);
%                         for m=1:length(LocalMaxima.LocalMaxInd)
%                             if LocalMaxima.IsValid(m)
%                                 temp = LocalMaxima.LocalMaxInd(m);
%                                 plot(KernelGrid(temp)*[1 1],[0 KernelValue(temp)],'b');
%                                 %temp = [LocalMaxima.LeftLocalMinInd(m) LocalMaxima.RightLocalMinInd(m)];
%                                 %plot(KernelGrid(temp),KernelValue(temp),'.k','MarkerSize',15);
%                             end
%                         end
%                         YLimA2 = get(gca,'YLim');
%                         set(gca,'YLim', [0 1.1]);

                        %% Plot the grid
                        
                        DwellLocation = FinalDwells{ph}{fc}.DwellLocation;

                        %axes(A1); hold on;
                        for d = 1:length(DwellLocation)
                            if DwellLocation(d)<max(YLim) && DwellLocation(d)>min(YLim)
                                plot(XLim,DwellLocation(d)*[1 1],':k','LineWidth',0.5);
                            end
                        end
                        
%                         axes(A2); hold on; YLimA2 = get(gca,'YLim'); YLimA2(1)=0; set(gca,'YLim',YLimA2);
%                         for d = 1:length(DwellLocation)
%                             if DwellLocation(d)<max(YLim) && DwellLocation(d)>min(YLim)
%                                 plot(DwellLocation(d)*[1 1],YLimA2,':k','LineWidth',0.5);
%                             end
%                         end
                        reply = input('Is this a good Cluster? [y]: ', 's');
                        if strcmp(reply,'y')
                            PauseClusters{ph}{fc}(c).IsGood = 1;
                            Count = Count+1;
                            if rem(Count,10)==0
                                disp(['Reached ' num2str(Count) ' good pause count']);
                            end
                        else
                            PauseClusters{ph}{fc}(c).IsGood = 0;
                        end
                        close(gcf);
                        
                        %Identify the Valid Local Maxima/Peaks in the Kernel Density
                        

                    end
                end
            end
        end
        save([DataPath filesep DataFile{df}(1:end-4) '_extra.mat'],'PauseClusters','FinalDwells');
    end

end