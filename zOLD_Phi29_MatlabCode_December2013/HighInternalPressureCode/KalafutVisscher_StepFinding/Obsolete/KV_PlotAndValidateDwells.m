function ValidatedDwells = KV_PlotAndValidateDwells(RawT, RawY, FiltT, FiltY, DwellInd, ContrastThr, MaxSeparation)
    % DwellInd(d).Start
    % DwellInd(d).Finish
    % DwellInd(d).Mean  
    % DwellInd(d).StartTime
    % DwellInd(d).FinishTime
    % DwellInd(d).DwellTime
    % DwellInd(d).DwellLocation
    %
    % RawT  - time    vector at 2500Hz
    % RawY  - contour vector at 2500Hz
    % FiltT - time vector at the bandwidth used for KV stepfinding
    % FiltY - contour vector at the bandwidth used for KV stepfinding
    %
    % Plots raw 2500Hz data in light gray
    % Plots raw data filtered by RawFiltFact in dark gray
    % Plots the staircase of the dwell candidates identified by KV step-finding
    % Uses custom Kernel Density Function to generate the side-histogram
    % Validates peaks in kernel density distribution using ContrastThr(eshold)
    %
    % MaxSeparation - the peak shouldn't be any further than that from a candidate dwell location
    % ContrastThr   - contrast threshold for ksdensity peak validation
    %
    % USE: ValidatedDwells = KV_PlotAndValidateDwells(RawT,RawY,FiltT,FiltT,DwellInd,ContrastThr,MaxSeparation)
    %
    % Gheorghe Chistol, 30 June 2011

    KernelFiltFact    = 10;  %filter down to 250Hz

    figure(   'Units','normalized','Position',[0.0051 0.0625 0.9883 0.8359],'PaperPosition',[0.1 0.1 10.8 6]); 
    A1 = axes('Units','normalized','Position',[0.0440 0.0654 0.3446 0.8754],'Layer','top','box','off'); hold on;
    B1 = axes('Units','normalized','Position',[0.5252 0.0654 0.3446 0.8754],'Layer','top','box','off'); hold on;
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

    for d=1:length(DwellInd)
        tempx = [DwellInd(d).StartTime     DwellInd(d).FinishTime];  %beginning/end of the current dwell
        tempy = [DwellInd(d).DwellLocation DwellInd(d).DwellLocation];
        x(end+1:end+2) = tempx;
        y(end+1:end+2) = tempy;
        plot(tempx,tempy,'b','LineWidth',3);
    end
    plot(x,y,'-b','LineWidth',1);

    % Plot a grid at each DwellLocation
    for d=1:length(DwellInd)
        plot(get(gca,'XLim'), DwellInd(d).DwellLocation*[1 1],':k','LineWidth',0.5);
    end

    %% Calculate the Adaptive Custom Kernel Density

    % Filter and Decimate the data (FaD) one point at a time
    FaD.Y     = []; %FaD = "Filtered and Decimated"
    FaD.StErr = []; % Y is the mean, StErr is the Standard Error
    
    for i = 1:floor(length(RawY)/KernelFiltFact)
        temp         = RawY((1+(i-1)*KernelFiltFact):(i*KernelFiltFact)); %raw data for the current FaD point
        FaD.Y(i)     = mean(temp);
        FaD.StErr(i) = std(temp)/sqrt(KernelFiltFact);
    end

    KernelGridDelta = median(FaD.StErr)/5;
    KernelGrid      = min(RawY):KernelGridDelta:max(RawY); %the grid on which we will build the kernel
    KernelValue     = 0*KernelGrid; %the values at each point in the grid, start with zero

    %add the kernel contribution for each filtered point
    for i=1:length(FaD.Y)
        %built it up one point at a time, updating the KernelValue for each FaD point
        KernelValue = KV_AddGausianContribution(KernelGrid, KernelValue, FaD.Y(i), FaD.StErr(i)); 
    end

    %% Plot the Custom Kernel Density on the Side
    A2 = axes('Units','normalized','Position',[0.3911 0.0654 0.1200 0.8754],'Layer','bottom','box','off'); hold on;
    B2 = axes('Units','normalized','Position',[0.8719 0.0654 0.1200 0.8754],'Layer','bottom','box','off'); hold on;
    SecondaryAxes = [A2 B2];
    
    for a=1:length(SecondaryAxes)
        axes(SecondaryAxes(a)); 
        % plot grid lines for dwell candidate locations
        YLim = [0 1.05*max(KernelValue)];
        for d=1:length(DwellInd)
            plot(DwellInd(d).DwellLocation*[1 1], YLim, ':k', 'LineWidth', 0.5);
        end
        set(gca,'YLim',YLim);

        %Plot the Kernel Density
        area(KernelGrid, KernelValue, 'FaceColor', rgb('YellowGreen'), 'LineStyle', 'none');
        plot(KernelGrid, KernelValue, '.k', 'MarkerSize', 1);
        set(gca,'XLim',[min(RawY) max(RawY)],'XTick',[]);
        camroll(90); %rotate side-histogram plot by 90 degrees to match the trace plot
    end
    
    %% Identify the Valid Local Maxima/Peaks in the Kernel Density
    LocalMaxima = KV_IdentifyLocalMaxima(KernelGrid, KernelValue, ContrastThr);

    plot(KernelGrid(LocalMaxima.LocalMaxInd), KernelValue(LocalMaxima.LocalMaxInd),'.b'); %mark all local maxima with blue dots
    plot(KernelGrid(LocalMaxima.LocalMinInd), KernelValue(LocalMaxima.LocalMinInd),'.r'); %mark all local minima with red dots

    for m=1:length(LocalMaxima.LocalMaxInd)
        if LocalMaxima.IsValid(m)
            % if the current local maximum is valid, i.e. has a large enough Contrast with respect to its baseline
            % mark all validated local maxima with a vertical blue line
            plot(KernelGrid(LocalMaxima.LocalMaxInd(m))*[1 1], [0 KernelValue(LocalMaxima.LocalMaxInd(m))],'-b'); 
        end
    end

    %% Validated Dwells based on the Local Maxima
    axes(B1);
    ValidatedDwells = KV_ValidateDwells(FiltT, FiltY, DwellInd, LocalMaxima, MaxSeparation);


    %% Plot the Validated Steps in red on the right plot
    x=[]; y=[]; DwellLocation =[];
    axes(B1);
    for d=1:length(ValidatedDwells)
        DwellLocation(d) =  ValidatedDwells(d).DwellLocation;    
        tempx = [ValidatedDwells(d).StartTime     ValidatedDwells(d).FinishTime];  %beginning/end of the current dwell
        tempy = [ValidatedDwells(d).DwellLocation ValidatedDwells(d).DwellLocation];

        if d==1 %very first validated dwell for this feedback cycle
            x = tempx; %start new dwell cluster from scratch 
            y = tempy;
        else
            %no longer the very first validated dwell 
            if ValidatedDwells(d).Start == ValidatedDwells(d-1).Finish+1
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
end