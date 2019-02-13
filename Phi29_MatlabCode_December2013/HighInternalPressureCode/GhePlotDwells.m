function GhePlotDwells(dwells,phageData,PlotColor)
% This function plots the dwells onto a figure, using the phageData for
% time and contour length information.
% 
% Gheorghe Chistol, May 24, 2010

%% dwells contains the following
% dwells.start
% dwells.end
% dwells.mean
% dwells.std
% dwells.Npts
% dwells.NptsAbove
hold on;
L=length(dwells.mean);
for i=1:L
    x=[phageData.time(dwells.start(i)) phageData.time(dwells.end(i))];
    y=[dwells.mean(i) dwells.mean(i)];
    line(x,y,'Color',PlotColor,'LineWidth',2);
    
    
    if (i~=L) %Connect to the next dwell, unless it's the last one
        x=[phageData.time(dwells.end(i)) phageData.time(dwells.start(i+1))];
        y=[dwells.mean(i) dwells.mean(i+1)];
        line(x,y,'Color',PlotColor,'LineWidth',1);
        StepSize = -(y(2)-y(1));
        StepSize = round(100*StepSize)/100;
        %text(x(1)+0.03,(y(1)+y(2))/2+1,[num2str(StepSize) 'bp']);
    end
end
