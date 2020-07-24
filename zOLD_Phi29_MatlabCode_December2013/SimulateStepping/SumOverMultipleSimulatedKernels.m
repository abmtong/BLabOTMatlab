X = -40:0.2:40;
Y = 0*X;
for i=1:length(Results)
    temp = interp1(Results(i).KernelX,Results(i).KernelY,X,'linear',0);
    Y = Y+temp;
end

figure;
%plot(X,Y,'b','LineWidth',1.5);
h=area(X,Y,'FaceColor',rgb('LightSkyBlue'));
set(gca,'XLim',[-30 40 ]);
set(gca,'XGrid','on');
xlabel('Contour Length Distance (bp)');
ylabel('Cumulative Kernel Density');
set(gca,'YTick',[]);
title('Simulated Data 10 + n*2.4 bp where n=1,2,3,4');