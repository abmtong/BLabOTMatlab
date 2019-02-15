function [outX, outY] = getPlotData()

ax = gca;
outX = ax.Children.XData;
outY = ax.Children.YData;