function ValidatedDwells = KV_PlotAndValidateDwells(RawT,RawY,FiltT,FiltT,DwellInd,ContrastThr,MaxSeparation)
% DwellInd(d).
%             Start
%             Finish
%             Mean
%             Var
%             StartTime
%             FinishTime
%             DwellTime
%             DwellLocation
%
% T - time    vector at 2500Hz
% Y - contour vector at 2500Hz
% KVT - time vector at the bandwidth used for KV stepfinding
% KVY - contour vector at the bandwidth used for KV stepfinding
%
% Plots raw 2500Hz data in light gray
% Plots raw data filtered by RawFiltFact in dark gray
% Plots the staircase of the dwell candidates identified by KV step-finding
% Uses raw data boxcar-filtered by SideHistFiltFact to generate the side-histogram
% Smoothes the side-histogram using kernel density with the same bin-size
% Validates peaks in kernel density distribution using ContrastThr(eshold)
% Only dwell candidates that correspond to a good ksdensity peak are accepted as valid dwells
%
% MaxSeparation - the peak shouldn't be any further than that from a candidate dwell location
% ContrastThr   - contrast threshold for ksdensity peak validation
% SideHistProp  - properties of the side-histogram that will be useful when considering merging dwells
%
% USE: [ValidatedDwells SideHistProp] = KV_PlotStepStaircase(T,Y,DwellInd,ContrastThr,NminPeaks,NminContr,MaxSeparation)
%
% Gheorghe Chistol, 29 June 2011

RawFiltFact = 25;  %filter down to 100Hz
FiltFact    = 25;  %filter down to 100Hz

figure(   'Units','normalized','Position',[0.0051 0.0625 0.9883 0.8359],'PaperPosition',[0.1 0.1 10.8 6]); 
A1 = axes('Units','normalized','Position',[0.0440 0.0654 0.3446 0.8754],'Layer','top','box','off'); hold on;
B1 = axes('Units','normalized','Position',[0.5252 0.0654 0.3446 0.8754],'Layer','top','box','off'); hold on;
MainAxes = [A1 B1];
for i=1:length(MainAxes)
    axes(MainAxes(i)); 
    plot(T,Y,'Color',0.8*[1 1 1]);
    t = FilterAndDecimate(T,RawFiltFact); y = FilterAndDecimate(Y,RawFiltFact);
    plot(t,y,'Color',0.4*[1 1 1],'LineWidth',1);
    axis([min(t) max(t) min(y)-0.05*range(y) max(y)+0.05*range(y)]);
    xlabel('Time (s)');
    set(gca,'YLim',[min(Y) max(Y)]); %see above
end
axes(B1); set(gca,'YTickLabel',{});
axes(A1); ylabel('DNA Contour Length (bp)');

%% Plot the KV steps in blue on the left plot
x=[]; y=[];
DwellLocation =[];
axes(A1);
for d=1:length(DwellInd)
    DwellLocation(d)=DwellInd(d).DwellLocation;
    tempx = [DwellInd(d).StartTime     DwellInd(d).FinishTime];  %beginning/end of the current dwell
    tempy = [DwellInd(d).DwellLocation DwellInd(d).DwellLocation];
    x(end+1:end+2) = tempx;
    y(end+1:end+2) = tempy;
    plot(tempx,tempy,'b','LineWidth',3);
end
plot(x,y,'-b','LineWidth',1);
XLim = get(gca,'XLim');
for i=1:length(DwellLocation)
    plot(XLim,DwellLocation(i)*[1 1],':k','LineWidth',0.5);
end
%% Make a New Axes for the Side-Histogram Display
A2 = axes('Units','normalized','Position',[0.3911 0.0654 0.1200 0.8754],'Layer','bottom','box','off'); hold on;
B2 = axes('Units','normalized','Position',[0.8719 0.0654 0.1200 0.8754],'Layer','bottom','box','off'); hold on;
SecondAxes = [A2 B2];

%first filter and decimate the data
FaD.Y     = [];
FaD.StDev = [];
FaD.StErr = [];

for i = 1:floor(length(Y)/FiltFact)
    temp         = Y((1+(i-1)*FiltFact):(i*FiltFact)); %the data for the current point
    FaD.Y(i)     = mean(temp);
    FaD.StDev(i) = std(temp);
    FaD.StErr(i) = std(temp)/sqrt(FiltFact);
end

KernelGridDelta = median(FaD.StErr)/5;
KernelGrid      = min(Y):KernelGridDelta:max(Y); %the grid on which we will build the kernel
KernelValue     = 0*KernelGrid; %the values at each point in the grid

%add the kernel contribution for each filtered point
for i=1:length(FaD.Y)
    KernelValue = KV_AddGausianContribution(KernelGrid,KernelValue,FaD.Y(i),FaD.StErr(i));
end

% plot grid lines for dwell candidate locations
YLim = [0 1.05*max(KernelValue)];
axes(A2);
for d=1:length(DwellInd)
    plot(DwellInd(d).Mean*[1 1],YLim,':k','LineWidth',0.5);
end
set(gca,'YLim',YLim);

%Plot the Kernel
area(KernelGrid,KernelValue,'FaceColor',rgb('YellowGreen'),'LineStyle','none');
plot(KernelGrid,KernelValue,'.k','MarkerSize',1);
set(gca,'XLim',[min(Y) max(Y)]); %see above
set(gca,'XTick',[]);
camroll(90); %rotate side-histogram plot by 90 degrees to match the trace plot

axes(B2); %plot the same on the right side histogram
% plot grid lines for dwell candidate locations
YLim = [0 1.05*max(KernelValue)];
for d=1:length(DwellInd)
    plot(DwellInd(d).Mean*[1 1],YLim,':k','LineWidth',0.5);
end
set(gca,'YLim',YLim);

%Plot the Kernel
area(KernelGrid,KernelValue,'FaceColor',rgb('YellowGreen'),'LineStyle','none');
plot(KernelGrid,KernelValue,'.k','MarkerSize',1);
set(gca,'XLim',[min(Y) max(Y)]); %see above
set(gca,'XTick',[]);
camroll(90); %rotate side-histogram plot by 90 degrees to match the trace plot

%% Identify the local maxima/peaks and compute their properties
LocalMaxima = KV_TestingKernel_IdentifyLocalMaxima(KernelGrid,KernelValue,ContrastThr);

plot(KernelGrid(LocalMaxima.LocalMaxInd),KernelValue(LocalMaxima.LocalMaxInd),'.b'); %mark all local maxima
plot(KernelGrid(LocalMaxima.LocalMinInd),KernelValue(LocalMaxima.LocalMinInd),'.r'); %mark all local minima

for m=1:length(LocalMaxima.LocalMaxInd)
    if LocalMaxima.IsValid(m)
        plot(KernelGrid(LocalMaxima.LocalMaxInd(m))*[1 1],[0 KernelValue(LocalMaxima.LocalMaxInd(m))],'-b'); %mark all validated local maxima
    end
end

%% Validated Dwells based on the Local Maxima
ValidatedDwells = KV_TestingKernel_ValidatePeaks(KVT,KVY,DwellInd,LocalMaxima,MaxSeparation);


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