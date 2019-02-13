function PlotDwells_Diagnostic(dwells,PhageData,FeedbackCycle)
% This function plots the dwells onto a figure, using the phageData for
% time and contour length information.
% 
% PlotDwells(dwells,PhageData,PlotColor,FeedbackCycle)
%
% Gheorghe Chistol, May 24, 2010

%% dwells contains the following
% dwells.start
% dwells.end
% dwells.mean
% dwells.std
% dwells.Npts
% dwells.NptsAbove

for d=1:length(dwells.mean)
    TempData = PhageData.contourFiltered{FeedbackCycle}(dwells.start(d):dwells.end(d));
    StErr(d) = std(TempData)./sqrt(length(TempData)); %this is the standard error
end
MedianStErr = median(StErr); %this defines the median of the StErr distribution

%plot the top 50% of the dwells in blue, the bottom 50% in red

hold on;
L=length(dwells.mean);
for i=1:L
    x=[PhageData.timeFiltered{FeedbackCycle}(dwells.start(i)) PhageData.timeFiltered{FeedbackCycle}(dwells.end(i))];
    y=[dwells.mean(i) dwells.mean(i)];
    if StErr(i)<MedianStErr
        line(x,y,'Color','b','LineWidth',2);
    else
        line(x,y,'Color','r','LineWidth',2);
    end
    
    if (i~=L) %Connect to the next dwell, unless it's the last one
        x=[PhageData.timeFiltered{FeedbackCycle}(dwells.end(i)) PhageData.timeFiltered{FeedbackCycle}(dwells.start(i+1))];
        y=[dwells.mean(i) dwells.mean(i+1)];
        line(x,y,'Color','k','LineWidth',1);
        StepSize = -(y(2)-y(1));
        StepSize = round(100*StepSize)/100;
        DisplayText = [num2str(StepSize) 'bp'];
        
        text(double(x(1)+0.03), double(mean(y)+1), DisplayText);
        
    end
end