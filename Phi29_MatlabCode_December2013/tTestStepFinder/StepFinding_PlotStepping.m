function FigureHandle=StepFinding_PlotStepping(Data,RawContour,RawTime,Dwells)
% This function plots the raw data, filtered data and stepping data on the
% same figure.
%
% USE: 
%
% Gheorghe Chistol, 16 March 2011
Alpha=0.05; %for fixing the plot axis limits
LimX = [min(Data.FilteredTime)-Alpha*range(Data.FilteredTime)        max(Data.FilteredTime)+Alpha*range(Data.FilteredTime)];
LimY = [min(Data.FilteredContour)-Alpha*range(Data.FilteredContour)  max(Data.FilteredContour)+Alpha*range(Data.FilteredContour)];

FigureHandle=figure('Units','normalized','Position',[0.0059    0.0625    0.4883    0.8359]); 
hold on;
set(gca,'Color',[1 1 1]);
%pre-filter raw data to 500 Hz
t=FilterAndDecimate(RawTime,5);
y=FilterAndDecimate(RawContour,5);
plot(t,y,'Color',0.9*[1 1 1]); %Plot the RawData
plot(Data.FilteredTime,Data.FilteredContour,'Color',0.5*[1 1 1]); %Plot the Filtered Data
set(gca,'XLim',LimX,'YLim',LimY);

%% Now Plot The Dwells
% Dwells.start
% Dwells.end
% Dwells.mean
% Dwells.std
% Dwells.Npts
% Dwells.NptsAbove
SteppingTime    = [];
SteppingContour = [];
TextX=[];
TextY=[]; %the coordinates where text will be placed
StepSize = [];
L=length(Dwells.mean);
for i=1:L
    x=[Data.FilteredTime(Dwells.start(i)) Data.FilteredTime(Dwells.end(i))];
    y=[Dwells.mean(i) Dwells.mean(i)];
    SteppingTime    = [SteppingTime    x];
    SteppingContour = [SteppingContour y];
    
    
    if (i~=L) %Connect to the next dwell, unless it's the last one
        x = [Data.FilteredTime(Dwells.end(i)) Data.FilteredTime(Dwells.start(i+1))];
        y = [Dwells.mean(i)                   Dwells.mean(i+1)];
        SteppingTime    = [SteppingTime    x];
        SteppingContour = [SteppingContour y];

        temp = -(y(2)-y(1));
        StepSize(end+1) = round(temp);
        TextX(end+1)    = x(1)+0.1;
        TextY(end+1)    = (y(1)+y(2))/2+1;
    end
end

plot(SteppingTime,SteppingContour,'Color','k','LineWidth',1);
for i=1:length(StepSize)
    text(TextX(i),TextY(i),[num2str(StepSize(i)) ' '],'FontSize',8);
end
legend('500Hz Raw Data','Filtered Data','Stepping Data');
xlabel('Time (s)');
ylabel('Contour Length (appropriate units)');

%     %Save the current figure as an image in a folder for later 
%     ImageFolderName=[analysisPath filesep 'StepFindingResults_Images'];
% 
%     if ~isdir(ImageFolderName);
%      mkdir(ImageFolderName);%create the directory
%     end
%     ImageFileName = [ImageFolderName filesep PhageData.file(1:end-4) '_' num2str(CurrentFeedbackCycle) '.png'];
%     saveas(H,ImageFileName);
%     close(H);