function Adaptive_PlotFinalResults(RawT,RawY,FiltT,FiltY,KernelDensity,FinalDwells,FinalDwellsValidated,CurrentFeedbackCycle,PhageFile,analysisPath,Bandwidth,s)
    % Plot the results, KV step-finding results on the left, Validated
    % Step-Finding results on the right, + the kernel density histogram
    %
    % USE: KV_PlotFinalResults_KernelDensity(RawT,RawY,FiltT,FiltY,KernelDensity,FinalDwells,FinalDwellsValidated,CurrentFeedbackCycle,PhageFile,analysisPath)
    %
    % Gheorghe Chistol, 14 Nov 2012

    figure(   'Units','normalized','Position',[0.0059    0.0612    0.9883  0.8372],'PaperPosition',[0.1 0.1 10.8 6]); 
    B1 = axes('Units','normalized','Position',[0.0598    0.0663    0.3800  0.8800],'Layer','top','box','on'); hold on;
    A1 = axes('Units','normalized','Position',[0.4476    0.0663    0.38    0.8800],'Layer','top','box','on'); hold on;
    C1 = axes('Units','normalized','Position',[0.8370    0.0663    0.15    0.8800],'Layer','top','box','on'); hold on;
    MainAxes = [A1 B1];
    for i=1:length(MainAxes)
        axes(MainAxes(i)); 
        plot(RawT, RawY, 'Color', 0.8*[1 1 1]);
        plot(FiltT, FiltY, 'Color', 0.5*[1 1 1],'LineWidth',1);
        
        set(gca,'XLim',[min(RawT) max(RawT)]);
        set(gca,'YLim',[min(RawY) max(RawY)]);
        xlabel('Time (s)');
    end
    axes(A1); set(gca,'YTickLabel',{});
    axes(B1); ylabel('DNA Contour Length (bp)');
    axes(C1); 

    for f = 1:length(KernelDensity) %there might be several fragments, due to slips
        plot(-KernelDensity{f}.KernelValue,KernelDensity{f}.KernelGrid,'b','LineWidth',1.5);
        hold on;
        PeakInd = KernelDensity{f}.LocalMaxima.LocalMaxInd(logical(KernelDensity{f}.LocalMaxima.IsValid)); %1 and 0 in logical/binary i.e. T/F
        
        plot(-KernelDensity{f}.KernelValue(PeakInd),KernelDensity{f}.KernelGrid(PeakInd),'.r','MarkerSize',15);
        %         KernelDensity{f}.LocalMaxima
        %                           KernelGrid: [1x1143 single]
        %                          KernelValue: [1x1143 single]
        %                          LocalMaxInd: [1x19 double]
        %                      LeftLocalMinInd: [1x19 double]
        %                     RightLocalMinInd: [1x19 double]
        %                              IsValid: [1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1]
        %                             Baseline: [1x19 single]
        %                         PeakContrast: [1x19 single]
        %                          LocalMinInd: [1x20 double]
    end
    xlabel('Kernel Density');
    set(gca,'YLim',[min(RawY) max(RawY)]); %axes are inverted here
    set(gca,'XLim',[-1.1 0]); %axes are inverted here
    set(gca,'XTick',[],'YTick',[]);
    
    %% Plot the Dwell Candidates on the Left Plot (A1)
    x=[]; y=[]; axes(A1);

    for d=1:length(FinalDwells.DwellLocation)
        tempx = [FinalDwells.StartTime(d)     FinalDwells.FinishTime(d)];  %beginning/end of the current dwell
        tempy = [FinalDwells.DwellLocation(d) FinalDwells.DwellLocation(d)];
        x(end+1:end+2) = tempx;
        y(end+1:end+2) = tempy;
        plot(tempx,tempy,'b','LineWidth',3);
    end
    plot(x,y,'-b','LineWidth',1);
    %plot(FiltT, FiltY, '.k','MarkerSize',10);
    
    % Plot a grid at each DwellLocation
    for d=1:length(FinalDwells.DwellLocation)
        plot(get(gca,'XLim'), FinalDwells.DwellLocation(d)*[1 1],':k','LineWidth',0.5);
    end

    axes(C1);
    % Plot a grid at each DwellLocation
    for d=1:length(FinalDwells.DwellLocation)
        plot(get(gca,'XLim'), FinalDwells.DwellLocation(d)*[1 1],':k','LineWidth',0.5);
    end
    
    %% Plot the Validated Steps in red on the right plot (B1)
    x=[]; y=[]; DwellLocation =[];
    axes(B1);
    for d=1:length(FinalDwellsValidated.DwellLocation)
        DwellLocation(d) =  FinalDwellsValidated.DwellLocation(d);    
        tempx = [FinalDwellsValidated.StartTime(d)     FinalDwellsValidated.FinishTime(d)];  %beginning/end of the current dwell
        tempy = FinalDwellsValidated.DwellLocation(d)*[1 1];

        if d==1 %very first validated dwell for this feedback cycle
            x = tempx; %start new dwell cluster from scratch 
            y = tempy;
        else
            %no longer the very first validated dwell 
            if FinalDwellsValidated.Start(d) == FinalDwellsValidated.Finish(d-1)
                %we have temporally consecutive dwells, the same dwell cluster
                %continue constructing the current cluster            
                x(end+1:end+2)   = tempx;
                y(end+1:end+2)   = tempy;
            else
                plot(x,y,'-k','LineWidth',1); %the previous cluster has ended, plot it
                x = tempx; %start new dwell cluster from scratch 
                y = tempy;
            end
        end
        plot(tempx,tempy,'k','LineWidth',3); %plot the level of the dwell so we can see it better
    end
    plot(x,y,'-k','LineWidth',1); %the very last cluster has ended, plot it

    XLim = get(gca,'XLim');
    for i=1:length(DwellLocation)
        plot(XLim,DwellLocation(i)*[1 1],':k','LineWidth',0.5);
    end

    for i=1:length(MainAxes)
        axes(MainAxes(i));
        title([PhageFile  ', FC#' num2str(CurrentFeedbackCycle) ', Section#' num2str(s) ', <Vel>=' num2str(round(range(FiltY)/range(FiltT))) 'bp/sec, f=' num2str(Bandwidth) 'Hz']);
    end
    %% Save the image as FIG and PNG
    ImageFolderName=[analysisPath filesep 'AdaptiveStepFinding_Images']; %Save the current figure as an image in a folder for later 

    if ~isdir(ImageFolderName);
        mkdir(ImageFolderName);%create the directory
    end

%     ImageFileName = [ImageFolderName filesep PhageFile '_' num2str(CurrentFeedbackCycle) '_' num2str(Bandwidth) 'Hz' '.fig'];
%     saveas(gcf,ImageFileName);
    ImageFileName = [ImageFolderName filesep PhageFile '_FC' num2str(CurrentFeedbackCycle) '_Sect' num2str(s) '_Band' num2str(Bandwidth) 'Hz' '.png'];
    saveas(gcf,ImageFileName); 
    %ImageFileName = [ImageFolderName filesep 'SICP2_' PhageFile '_FC' num2str(CurrentFeedbackCycle) '_Sect' num2str(s) '_Band' num2str(Bandwidth) 'Hz' '.fig'];
    %saveas(gcf,ImageFileName); 
    close(gcf);
end