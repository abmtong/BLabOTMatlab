function [PauseDuration PauseDurationError PauseDensity PauseDensityError]=AnalyzePauses(PauseClusters, MinPauseDuration)



% Calculating Pause Density
TotalNumberOfPauses=0; for i=1:length(PauseClusters)
TotalNumberOfPauses=TotalNumberOfPauses+PauseClusters{i}.NumberOfPauses;
end
TotalLength=0; for i=1:length(PauseClusters)
if ~isnan(PauseClusters{i}.TotalDNAContourLength)
TotalLength=TotalLength+PauseClusters{i}.TotalDNAContourLength;
end
end
PauseDensity=TotalNumberOfPauses/(TotalLength/1000);
PauseDensityError=sqrt(TotalNumberOfPauses)/(TotalLength/1000);

%Calculating Pause Duration
TimeBinning=[0:2:100]';

PausesDurationVec=[];for i=1:length(PauseClusters)
for j=1:length(PauseClusters{i}.Start)
    %if PauseClusters{i}.End(j)-PauseClusters{i}.Start(j)<20
        PausesDurationVec=[PausesDurationVec PauseClusters{i}.End(j)-PauseClusters{i}.Start(j)];
    %end
end
end
PauseDurationVec=PausesDurationVec';



figure; HistPDur=hist(PauseDurationVec,TimeBinning');
ind=(HistPDur>0);
HistPDur=HistPDur(ind)';
TimeBinning=TimeBinning(ind);
plot(TimeBinning,HistPDur);
hold on;
fitOpts = fitoptions('Method','NonlinearLeastSquares',...
        'Lower',[40 0.0001 1],...
        'Upper',[80 10 20],...
        'Startpoint',[40 1 2]);
       eqn = 'a*exp(-b*x)+c';
        fitType = fittype(eqn,'indep','x','options',fitOpts);
        [fitRes,gof] = fit(TimeBinning,HistPDur,fitType);
        aValue=['a Value is = ' Num2Str(fitRes.a)];
        bValue=['b value is = ' Num2Str(fitRes.b)];
        cValue=['c value is = ' Num2Str(fitRes.c)];
        text(1000,500,aValue,'FontSize',8,'Color','k');
        text(1000,500,bValue,'FontSize',8,'Color','k');
       text(1000,500,cValue,'FontSize',8,'Color','k');
        plot(fitRes);

PauseDuration=mean(PauseDurationVec);
PauseDurationError=std(PauseDurationVec)/sqrt(length(PauseDurationVec));


end