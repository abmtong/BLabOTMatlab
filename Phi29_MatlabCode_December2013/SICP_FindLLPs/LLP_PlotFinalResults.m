function LLP_PlotFinalResults(RawT,RawY,FiltT,FiltY,FinalDwells,FinalDwellsConsolidated,analysisPath,CurrentPhageName,s)
% Plot the results of pause finding in three stages
%   Left: raw data and filtered data only
% Center: initial SICP dwell/pause analysis
%  Right: consolidated dwells/pauses, using the MinStep and MinDuration parameters
%
% USE: % LLP_PlotFinalResults(RawT,RawY,FiltT,FiltY,FinalDwells,FinalDwellsConsolidated,analysisPath,CurrentPhageName,s)
%
% Gheorghe Chistol, 03 Dec 2012

CurrentFeedbackCycle = FinalDwells.FeedbackCycle;
Bandwidth = FinalDwells.Bandwidth ;

% Plot the results, KV step-finding results on the left, Validated
    % Step-Finding results on the right, + the kernel density histogram
    %
    % USE: KV_PlotFinalResults_KernelDensity(RawT,RawY,FiltT,FiltY,KernelDensity,FinalDwells,FinalDwellsValidated,CurrentFeedbackCycle,PhageFile,analysisPath)
    %
    % Gheorghe Chistol, 14 Nov 2012

    figure(   'Units','normalized','Position',[0.0059    0.0612    0.9883    0.8372],'PaperPosition',[0.1 0.1 10.8 6]); 
    A1 = axes('Units','normalized','Position',[0.0524    0.0663    0.3100    0.8800],'Layer','top','box','on'); hold on;
    B1 = axes('Units','normalized','Position',[0.3674    0.0663    0.3100    0.8800],'Layer','top','box','on'); hold on;
    C1 = axes('Units','normalized','Position',[0.6822    0.0663    0.3100    0.8800],'Layer','top','box','on'); hold on;
    
    %% Plot the raw data and filtered data
    MainAxes = [A1 B1 C1];
    FilterColor{1} = 0*[1 1 1];
    FilterColor{2} = 0.5*[1 1 1];
    FilterColor{3} = 0.5*[1 1 1];
    for i=1:length(MainAxes)
        axes(MainAxes(i)); 
        plot(RawT, RawY, 'Color', 0.85*[1 1 1]);
        plot(FiltT,FiltY,'Color', FilterColor{i},'LineWidth',1);
        set(gca,'XLim',[min(RawT) max(RawT)]);
        set(gca,'YLim',[min(RawY) max(RawY)]);
        xlabel('Time (s)');
    end
    axes(A1); ylabel('DNA Contour Length (bp)');
    axes(B1); set(gca,'YTickLabel',{});
    axes(C1); set(gca,'YTickLabel',{});
    
    %% Plot the Final Dwells in black on the Center Plot (B1)
    axes(B1); x=[]; y=[];
    for d=1:length(FinalDwells.DwellLocation)
        tempx = [FinalDwells.StartTime(d)     FinalDwells.FinishTime(d)];  %beginning/end of the current dwell
        tempy = [FinalDwells.DwellLocation(d) FinalDwells.DwellLocation(d)];
        x(end+1:end+2) = tempx;
        y(end+1:end+2) = tempy;
        plot(tempx,tempy,'b','LineWidth',3);
    end
    plot(x,y,'-b','LineWidth',1);
    XLim = get(gca,'XLim');
    for d=1:length(FinalDwells.DwellLocation) % Plot a grid at each DwellLocation
        plot([FinalDwells.FinishTime(d) XLim(2)], FinalDwells.DwellLocation(d)*[1 1],':k','LineWidth',0.5);
    end

    %% Plot the Final Dwells Consolidated in blue on the right plot (C1)
    axes(C1); x=[]; y=[];     
    for d=1:length(FinalDwellsConsolidated.DwellLocation)
        tempx = [FinalDwellsConsolidated.StartTime(d)     FinalDwellsConsolidated.FinishTime(d)];  %beginning/end of the current dwell
        tempy = [FinalDwellsConsolidated.DwellLocation(d) FinalDwellsConsolidated.DwellLocation(d)];
        x(end+1:end+2) = tempx;
        y(end+1:end+2) = tempy;
        plot(tempx,tempy,'k','LineWidth',3);
    end
    plot(x,y,'-k','LineWidth',1);
    
    XLim = get(gca,'XLim');
    for d=1:length(FinalDwellsConsolidated.DwellLocation) % Plot a grid at each DwellLocation
        plot([XLim(1) FinalDwellsConsolidated.StartTime(d)], FinalDwellsConsolidated.DwellLocation(d)*[1 1],':k','LineWidth',0.5);
    end

    axes(A1);
    if isnan(s) %if section # is given as NaN, this is a summary for all sections
        title([CurrentPhageName ', FC#' num2str(CurrentFeedbackCycle) ', SUMMARY, <Vel>=' num2str(round(range(FiltY)/range(FiltT))) 'bp/sec, f=' num2str(Bandwidth) 'Hz']);
    else
        title([CurrentPhageName ', FC#' num2str(CurrentFeedbackCycle) ', Section#' num2str(s) ', <Vel>=' num2str(round(range(FiltY)/range(FiltT))) 'bp/sec, f=' num2str(Bandwidth) 'Hz']);
    end
    %% Save the image as FIG and PNG
    ImageFolderName=[analysisPath filesep 'AnalysisLLP_Images']; %Save the current figure as an image in a folder for later 
    if ~isdir(ImageFolderName);
        mkdir(ImageFolderName);%create the directory
    end
    if isnan(s)
        ImageFileName = [ImageFolderName filesep CurrentPhageName '_FC' num2str(CurrentFeedbackCycle) '_SUMMARY_Band' num2str(Bandwidth) 'Hz' '.png'];
    else
        ImageFileName = [ImageFolderName filesep CurrentPhageName '_FC' num2str(CurrentFeedbackCycle) '_Sect' num2str(s) '_Band' num2str(Bandwidth) 'Hz' '.png'];
    end
    saveas(gcf,ImageFileName); 
    close(gcf);
end