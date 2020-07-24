function merge2graphs()
fprintf('Click first graph\n')
pause(2)
ax1 = gca;
fprintf('Click second graph\n')
pause(2)
ax2 = gca;

x1 = ax1.Children.XData;
y1 = ax1.Children.YData;
x2 = ax2.Children.XData;
y2 = ax2.Children.YData;

figure('Name','Merged graphs')
plot(x1, y1)
hold on
plot(x2, y2)