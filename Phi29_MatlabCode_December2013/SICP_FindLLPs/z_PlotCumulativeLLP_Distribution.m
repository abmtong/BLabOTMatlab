function z_PlotLLPHistograms(Dwells)
    FillingMarks = [40 60 80 90 95 100 105];
    DnaLength    = 21000;
    GenomeLength = 19300;
    HistBins = 0.25:0.5:50;
    MinStep = -20;
    MaxStep = 20;
    
    Dwells.Filling = (DnaLength-Dwells.Location)/GenomeLength*100; %in %
    MinFilling = FillingMarks(1:end-1);
    MaxFilling = FillingMarks(2:end);

    figure; hold on;
    for f = 1:length(MinFilling)
        IndKeep1 = Dwells.Filling>=MinFilling(f) & Dwells.Filling<MaxFilling(f);
        IndKeep2 = Dwells.SizeStepAfter>MinStep & Dwells.SizeStepAfter<MaxStep;
        IndKeep = logical(IndKeep1.*IndKeep2);
%         sum(IndKeep)
%         if sum(IndKeep)>0;
%             Color={'b' 'r' 'k' 'm'};    
%             ColorInd = 1+rem(f,length(Color));
%             [N X] = hist(Dwells.Duration(IndKeep),HistBins);
%             plot(X,N,'-','Color',Color{ColorInd});
%             set(gca,'XLim',[0 max(HistBins)]);
%             xlabel('Dwell Duration (s)');
%             ylabel('Counts');
%             %title(['Capsid Filling ' num2str(MinFilling(f)) '-' num2str(MaxFilling(f)) '%'])
%             set(gca,'XScale','log');
%             set(gca,'YScale','log');
%         end
        
        Color={'r' 'b' 'k' 'g' 'm' 'y'};
        %
        if sum(IndKeep)>0
            [T P] = z_ComputeCumulativeDistribution(Dwells.Duration(IndKeep));
            ColorInd = 1+rem(f,length(Color));
            plot(T,P,'-','Color',Color{ColorInd},'LineWidth',2);
            %title(['Capsid Filling ' num2str(MinFilling(f)) '-' num2str(MaxFilling(f)) '%'])
            set(gca,'XScale','log');
        end
        
    end
    legend('40-60% Filling','60-80% Filling','80-90% Filling','90-95% Filling','95-100% Filling','100-105% Filling','Location','se');
    xlabel('Dwell Duration (s)');
    ylabel('Cumulative Probability');
    set(gca,'Box','on');
end