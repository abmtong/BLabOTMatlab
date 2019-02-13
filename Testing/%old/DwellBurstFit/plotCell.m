function plotCell(xData,yData)
%plots the data in cell array xData, yData

if ~iscell(ydata)
    temp = yData;
    yData = cell(1);
    ydata{1}=temp;
end


for i = 1:length(xData)
    plot(xData{i},yData{i});
end