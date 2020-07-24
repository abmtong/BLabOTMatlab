function StepFinding_ATPgS_SortThroughAfterPortions()
    % Use the results from StepFinding_ATPgS_StepsAfter_New()
    % PauseClusters{ph}{fc}.AfterIsGood
    % PauseClusters{ph}{fc}.AfterData
    % PauseClusters{ph}{fc}.AfterData.Tstart
    % PauseClusters{ph}{fc}.AfterData.Tstop
    % PauseClusters{ph}{fc}.AfterData.KernelX
    % PauseClusters{ph}{fc}.AfterData.KernelY
    %
    % Gheorghe Chistol, 3 August 2011
    
    addpath([pwd filesep 'KalafutVisscher_StepFinding' filesep], '-end'); %where the KV scripts are located
    global analysisPath;
    [DataFile DataPath] = uigetfile([ [analysisPath filesep ] '*_ResultsKV_AfterExtra.mat'], 'Please select the AfterExtra Results file','MultiSelect', 'on');
    if ~iscell(DataFile)
        temp=DataFile; clear DataFile; DataFile{1} = temp;
    end
%     Cumulative.KernelX = 0:0.1:40;
%     Cumulative.KernelY = 0*Cumulative.KernelX;
    KernelFiltFact = 10; %filter from 2500Hz down to 250Hz
    
    CumulativeValidData = [];
    %load one file at a time
    for df=1:length(DataFile)
        clear PauseClusters FinalDwells; load([DataPath filesep DataFile{df}]);
        %go through all the elements of PauseClusters{phage}{feedbackcycle}
        for ph=1:length(PauseClusters) %ph is the PhageFile index
            for fc=1:length(PauseClusters{ph}) %fc is the FeedbackCycle index
                if ~isempty(PauseClusters{ph}{fc})
                    for c=1:length(PauseClusters{ph}{fc}) %c is the Cluster index
                        if PauseClusters{ph}{fc}(c).AfterIsGood
                            %we have a valid Before portion
                            figure('Units','normalized','Position',[0.0029    0.3906    0.4941    0.5521]);
                            temp = find((FinalDwells{ph}{fc}.PhageFile==filesep)==1,1,'Last');
                            SaveFile = [FinalDwells{ph}{fc}.PhageFile(temp+1:end-4) '_fc' num2str(FinalDwells{ph}{fc}.FeedbackCycle) '_c' num2str(c)];

                            
                            After = PauseClusters{ph}{fc}(c).AfterData;
                            Tstart = After.Tstart;
                            Tstop  = After.Tstop;
                            
                            RawT  = FinalDwells{ph}{fc}.RawTime;
                            RawY  = FinalDwells{ph}{fc}.RawCont;
                            FiltT = FilterAndDecimate(RawT,KernelFiltFact);
                            FiltY = FilterAndDecimate(RawY,KernelFiltFact);
                            RawInd  = RawT>Tstart & RawT<Tstop;
                            FiltInd = FiltT>Tstart & FiltT<Tstop;

                            % Trace Plot
                            MainA = axes('Position',[0.0904    0.1100    0.5022    0.7296],'Box','on'); hold on;
                            plot(RawT(RawInd),RawY(RawInd),'Color',0.8*[1 1 1]);
                            plot(FiltT(FiltInd),FiltY(FiltInd),'Color',0.4*[1 1 1],'LineWidth',2);
                            XLim = [Tstart Tstop];
                            YLim = [min(RawY(RawInd)) max(RawY(RawInd))];
                            set(gca,'YLim',YLim);
                            if range(XLim)<1
                                set(gca,'XLim',[XLim(2)-1 XLim(2) ]); %for clarity
                            else
                                set(gca,'XLim',XLim);
                            end
                            xlabel('Time (s)');
                            ylabel('Contour (bp)');
                            title(SaveFile,'Interpreter','none');                                                        
                            
                            % Side Histogram Plot
                            clear global KernelX KernelY LocalMaxInd;
                            global KernelX KernelY LocalMaxInd;   
                            MainB = axes('Position',[0.6030    0.1100    0.3496    0.7296],'Box','on','Layer','top'); hold on;
                            [KernelX KernelY] = KV_CalculateCustomKernelDensity(RawY(RawInd),KernelFiltFact); 
                            LocalMaxInd = StepFinding_FindLocalMaxInd(KernelY);
                            OffsetInd = LocalMaxInd(end);
                            area(KernelX,KernelY,'FaceColor',rgb('Gold'),'LineWidth',1);
                                
                            set(gca,'YLim',[0 1.1]);
                            set(gca,'XLim',YLim);
                            set(gca,'XGrid','on','XTick',KernelX(OffsetInd)+[-31 -21 -11 0],'XTickLabel',[-31 -21 -11 0]);
                            set(gca,'YTick',[]);
                            camroll(90);
                            % label the local maxima

                            for m = 1:length(LocalMaxInd)
                                plot(KernelX(LocalMaxInd(m)),KernelY(LocalMaxInd(m)),'.b','MarkerSize',15);
                            end
                            
                            %draw on the grid for the main plot
                            axes(MainA);
                            GridMarks = [0 -11 -21 -31]+KernelX(OffsetInd);
                            for g=1:length(GridMarks)
                            	plot(XLim,GridMarks(g)*[1 1],':k','LineWidth',0.5);
                            end
                            axes(MainB); %scwitch focus to the MainB axes
                         
                            StepFinding_ATPgS_TagAfterPortion(KernelX,KernelY,LocalMaxInd);
                            %keyboard;
                            reply = input('Press any key to move on: ', 's');
                            
                            global Peak1 Peak2 Offset;
                            if ~isempty(Peak1.Ind) && ~isempty(Peak2.Ind) && ~isempty(Offset.Ind)
                                AfterValidData.Peak1Ind    = Peak1.Ind;
                                AfterValidData.Peak2Ind    = Peak2.Ind;
                                AfterValidData.OffsetInd   = Offset.Ind;
                                AfterValidData.KernelX     = KernelX;
                                AfterValidData.KernelY     = KernelY;
                                AfterValidData.LocalMaxInd = LocalMaxInd;                                
                                PauseClusters{ph}{fc}(c).AfterIsValid = 1;
                                PauseClusters{ph}{fc}(c).AfterValidData = AfterValidData;
                                if isempty(CumulativeValidData)
                                    clear CumulativeValidData;
                                    CumulativeValidData(1) = AfterValidData;
                                else
                                    CumulativeValidData(end+1) = AfterValidData;
                                end
                                
                                %save the screenshot
                                SaveDir = [analysisPath filesep 'AfterStepCensusSave'];
                                if ~isdir(SaveDir)
                                    mkdir(SaveDir);
                                end
                                saveas(gcf,[SaveDir filesep SaveFile],'png');
                            end
                            clear global Peak1 Peak2 Offset Status;
                            close(gcf);
                        end
                    end
                end
            end
        end
        save([DataPath filesep DataFile{df}(1:end-4) '_AfterValid.mat'],'FinalDwells','PauseClusters','CumulativeValidData');
    end
end

    % reply = input('Is this Before portion good? [b]: ', 's');
% if strcmp(reply,'b')
% end
% saveas(gcf,[SaveFolder filesep SaveFile],'png');
% Add the current Kernel Density to the cumulative KernelDensity
% temp = interp1(Before.KernelX-OffsetVal,Before.KernelY,KernelX,'linear',0);
% KernelY = KernelY+temp;