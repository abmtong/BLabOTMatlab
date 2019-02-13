function KV_PlotFinalResults(RawT,RawY,FiltT,FiltY,FinalDwells,FinalDwellsValidated,CurrentFeedbackCycle,PhageFile,analysisPath)
    % Plot the results, KV step-finding results on the left, Validated
    % Step-Finding results on the right
    %
    % Gheorghe Chistol, 6 July 2011

    figure(   'Units','normalized','Position',[0.0073    0.0664    0.8199    0.8333],'PaperPosition',[0.1 0.1 10.8 6]); 
    A1 = axes('Units','normalized','Position',[0.0500    0.0600    0.4700    0.8800],'Layer','top','box','off'); hold on;
    B1 = axes('Units','normalized','Position',[0.5254    0.0600    0.4700    0.8800],'Layer','top','box','off'); hold on;
    MainAxes = [A1 B1];
    for i=1:length(MainAxes)
        axes(MainAxes(i)); 
        plot(RawT, RawY, 'Color', 0.8*[1 1 1]);
        plot(FiltT, FiltY, 'Color', 0.5*[1 1 1],'LineWidth',1);
        set(gca,'XLim',[min(RawT) max(RawT)]);
        set(gca,'YLim',[min(RawY) max(RawY)]);
        xlabel('Time (s)');
    end
    axes(A1); ylabel('DNA Contour Length (bp)');
    axes(B1); set(gca,'YTickLabel',{});


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
            if FinalDwellsValidated.Start(d) == FinalDwellsValidated.Finish(d-1)+1
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
        title([PhageFile  ', FC#' num2str(CurrentFeedbackCycle) ' MeanVel=' num2str(round(range(FiltY)/range(FiltT))) 'bp/sec']);
    end
    %% Save the image as FIG and PNG
    ImageFolderName=[analysisPath filesep 'StepFindingResultsKV_Images']; %Save the current figure as an image in a folder for later 

    if ~isdir(ImageFolderName);
        mkdir(ImageFolderName);%create the directory
    end

    ImageFileName = [ImageFolderName filesep PhageFile '_' num2str(CurrentFeedbackCycle) '.fig'];
    saveas(gcf,ImageFileName);
    ImageFileName = [ImageFolderName filesep PhageFile '_' num2str(CurrentFeedbackCycle) '.png'];
    saveas(gcf,ImageFileName); 
    close(gcf);
end