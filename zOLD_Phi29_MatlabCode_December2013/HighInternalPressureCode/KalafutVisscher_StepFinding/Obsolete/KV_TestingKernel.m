function KV_TestingKernel(DwellInd,RawT,RawY,FiltT,FiltY)
%
%
%
figure('Units','normalized','Position',[0 0.0521 1.0000 0.8568]);
FiltFact = 25; %filter from 2500Hz down to 100Hz
ContrastThr = 1.5; %contrast threshold for peak validation
%% Plot the RawData, FiltData
A1 = axes('Position',[0.0527 0.0654 0.3192 0.8754],'Layer','top','Box','on');
hold on;
plot(RawT,RawY,'Color',0.75*[1 1 1]);
plot(FiltT,FiltY,'Color',0.4*[1 1 1]);
XLim = [min(RawT) max(RawT)];
YLim = [min(RawY) max(RawY)];
set(gca,'XLim',XLim,'YLim',YLim);
xlabel('Time (s)');
ylabel('DNA Contour Length (bp)');

% DwellInd = 1x23 struct array with fields:
%     Start
%     Finish
%     Mean
%     Var ignore this one

% plot grid lines for dwell candidate locations
for d=1:length(DwellInd)
    plot(XLim,DwellInd(d).Mean*[1 1],':','LineWidth',0.5);
end

%% Plot the Custom Kernel Density with FilterandDecimated data, Std
A2 = axes('Position',[0.3743 0.0654 0.1200 0.8754],'Layer','top','Box','off');
hold on;
axes(A2);
%first filter and decimate the data
FaD.Y     = [];
FaD.StDev = [];
FaD.StErr = [];

for i = 1:floor(length(RawY)/FiltFact)
    temp         = RawY((1+(i-1)*FiltFact):(i*FiltFact)); %the data for the current point
    FaD.Y(i)     = mean(temp);
    FaD.StDev(i) = std(temp);
    FaD.StErr(i) = std(temp)/sqrt(FiltFact);
end

KernelGridDelta = median(FaD.StErr)/5;
KernelGrid      = min(RawY):KernelGridDelta:max(RawY); %the grid on which we will build the kernel
KernelValue     = 0*KernelGrid; %the values at each point in the grid

%add the kernel contribution for each filtered point
for i=1:length(FaD.Y)
    KernelValue = KV_AddGausianContribution(KernelGrid,KernelValue,FaD.Y(i),FaD.StErr(i));
end

% plot grid lines for dwell candidate locations
YLim = [0 1.05*max(KernelValue)];
set(gca,'YLim',YLim);
for d=1:length(DwellInd)
    plot(DwellInd(d).Mean*[1 1],YLim,':k','LineWidth',0.5);
end

%Plot the Kernel
area(KernelGrid,KernelValue,'FaceColor',rgb('YellowGreen'),'LineStyle','none');
plot(KernelGrid,KernelValue,'.k','MarkerSize',1);
set(gca,'XLim',[min(RawY) max(RawY)]); %see above
camroll(90); %rotate side-histogram plot by 90 degrees to match the trace plot
LocalMaxima = KV_TestingKernel_IdentifyLocalMaxima(KernelGrid,KernelValue,ContrastThr);
title('Custom Kernel');
end