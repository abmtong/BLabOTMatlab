function plotCell(xData,yData)
%plots the data in cell array xData, yData

figure('Name',[inputname(1) ' vs ' inputname(2)])
hold on
for i = 1:length(xData)
    plot(xData{i},yData{i});
end
hold off
end