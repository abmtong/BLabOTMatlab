% We detect the dwells and bursts using the tTest
close all;
%% load the data
load('SamplePhi29Trace.mat'); %vectors Time and Contour
Data.Time = Time;
Data.Contour = Contour;

%% Calculate Simple tTest and plot
WindowSize = 10;
AvgNum = 10;
tTestThr = 1e-4;

Data = tTest_Bare(Data, AvgNum, WindowSize);
XLim = [min(Data.Time) max(Data.Time)];
YLim = [min(Data.Contour) max(Data.Contour)];

figure('Units','normalized','Position',[0.0059 0.0625 0.4883 0.8359]); 
TopAxes = axes('Position',[0.1300 0.3614 0.7750 0.59]);
hold on;
plot(Data.Time,Data.Contour,'Color',0.8*[1 1 1]);
plot(Data.FilteredTime,Data.FilteredContour,'Color','b');
set(gca,'XLim',XLim,'YLim',YLim);
set(gca,'XTickLabel',[]);
set(gca,'Box','on','Layer','top');
ylabel('DNA Contour Length (bp)');
title(['tTestThr = ' num2str(tTestThr) ', tTestWin = ' num2str(WindowSize) 'pts, FilterFactor = ' num2str(AvgNum)]);

BottomAxes = axes('Position',[0.1300 0.0648 0.7750 0.2903]);
hold on;
plot(Data.FilteredTime, Data.sgn,'-k');
plot(Data.FilteredTime, Data.sgn,'.b');
set(gca,'YScale','log');
set(gca,'XLim',XLim,'YLim',[min(Data.sgn) max(Data.sgn)]);
set(gca,'Box','on','Layer','top');
plot(XLim,tTestThr*[1 1],':r');
xlabel('Time (s)');
ylabel('tTest Significance');


%% Find Transitions
DwellsBursts = tTest_FindDwellsBursts(Data,tTestThr);
axes(TopAxes);
plot(DwellsBursts.LadderTime,DwellsBursts.LadderContour,'-r','LineWidth',2);
for b = 1:length(DwellsBursts.BurstDuration)
    ind = [DwellsBursts.BurstStartInd(b) DwellsBursts.BurstFinishInd(b)];
    plot(Data.FilteredTime(ind),DwellsBursts.DwellMean(b:b+1),'g','LineWidth',2);
end
% 
%     DwellsBursts.DwellStartInd  = DwellStartInd;
%     DwellsBursts.DwellFinishInd = DwellFinishInd;
%     DwellsBursts.DwellMean      = DwellMean;
%     DwellsBursts.DwellStd       = DwellStd;
%     DwellsBursts.DwellNpts      = DwellNpts;
%     DwellsBursts.DwellDuration  = DwellDuration;
%     DwellsBursts.BurstStartInd  = BurstStartInd;
%     DwellsBursts.BurstFinishInd = BurstFinishInd;
%     DwellsBursts.BurstMean      = BurstMean;
%     DwellsBursts.BurstStd       = BurstStd;
%     DwellsBursts.BurstNpts      = BurstNpts;
%     DwellsBursts.BurstDuration  = BurstDuration;
%     DwellsBursts.LadderTime     = LadderTime;
%     DwellsBursts.LadderContour  = LadderContour;
