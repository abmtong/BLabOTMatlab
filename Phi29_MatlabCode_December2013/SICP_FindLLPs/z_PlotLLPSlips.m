function Slips = z_PlotLLPSlips(Dwells)
    FillingMarks = [52 63];
    DnaLength    = 12500;
    GenomeLength = 19300;
    HistBins = 0.25:0.5:50;
    
    Dwells.Filling = (DnaLength-Dwells.Location)/GenomeLength*100; %in %
%     MinFilling = FillingMarks(1:end-1);
%     MaxFilling = FillingMarks(2:end);

    Slips.MinFilling       = FillingMarks(1:end-1);
    Slips.MaxFilling       = FillingMarks(2:end);
    Slips.PackagedDistance = NaN*Slips.MinFilling;
    Slips.SlipDistance     = NaN*Slips.MinFilling;
    Slips.SlipNumber       = NaN*Slips.MinFilling;
    Slips.SlipFrequency    = NaN*Slips.MinFilling;
    
    for f = 1:length(Slips.MinFilling)
        IndKeep1 = Dwells.Filling>=Slips.MinFilling(f) & Dwells.Filling<Slips.MaxFilling(f);
        IndKeep2 = Dwells.SizeStepAfter<0;
        IndKeep = logical(IndKeep1.*IndKeep2);
        

        CurrSlipSizes = Dwells.SizeStepAfter(IndKeep);
        CurrSlipLocation = Dwells.Filling(IndKeep);
        CurrSlipLocation = CurrSlipLocation(~isnan(CurrSlipSizes));
        CurrStepSizes = Dwells.SizeStepAfter(IndKeep1);
        CurrSlipSizes = CurrSlipSizes(~isnan(CurrSlipSizes));
        CurrStepSizes = CurrStepSizes(~isnan(CurrStepSizes));
        
        Slips.SlipSizes{f}        = CurrSlipSizes;
        Slips.SlipLocation{f}     = CurrSlipLocation;
        Slips.PackagedDistance(f) = sum(CurrStepSizes);
        Slips.SlipDistance(f)     = -sum(CurrSlipSizes);
        Slips.SlipNumber(f)       = length(CurrSlipSizes);
        Slips.SlipFrequency(f)    = Slips.SlipNumber(f)/Slips.PackagedDistance(f);
        Slips.SlipOverPackaged(f) = Slips.SlipDistance(f)/Slips.PackagedDistance(f);
        [L P] = z_ComputeCumulativeDistribution(-CurrSlipSizes);
        Slips.CumulativeDistr(f).L = L;
        Slips.CumulativeDistr(f).P = P;
        %keyboard

    end
    
    %% plot the slip frequency
    figure; hold on;
    for f = 1:length(Slips.MinFilling)
       x = [Slips.MinFilling(f)*[1 1] Slips.MaxFilling(f)*[1 1]];
       y = [0 Slips.SlipFrequency(f)*[1 1]*1000 0];
       patch(x,y,'b');
    end
    xlabel('Capsid Filling'); ylabel('Slips Per Kb of DNA Packaged');
    set(gca,'Box','on','Layer','top'); 
    
    %% plot the Slip Over Packaged Distance
    figure; hold on;
    for f = 1:length(Slips.MinFilling)
       x = [Slips.MinFilling(f)*[1 1] Slips.MaxFilling(f)*[1 1]];
       y = [0 Slips.SlipOverPackaged(f)*[1 1] 0];
       patch(x,y,'m');
    end
    xlabel('Capsid Filling'); ylabel('Length of Slips Divided By Length DNA Packaged');
    set(gca,'Box','on','Layer','top'); 
    
    %% Plot cumulative slip size distribution
    Color={'r' 'b' 'k' 'g' 'm' 'y'};
    figure; hold on;
    for f = 1:length(Slips.MinFilling)
        ColorInd = 1+rem(f,length(Color));
        L = Slips.CumulativeDistr(f).L;
        P = Slips.CumulativeDistr(f).P;
        plot(L,P,'-','Color',Color{ColorInd},'LineWidth',2);
        %title(['Capsid Filling ' num2str(MinFilling(f)) '-'
        %num2str(MaxFilling(f)) '%'])
    end
    legend('40-60% Filling','60-80% Filling','80-90% Filling','90-95% Filling','95-100% Filling','100-105% Filling');
    set(gca,'XTick',[0 10 20:20:120]);
    xlabel('Slip Size (bp)');
    ylabel('Cumulative Probability');
    title('Slip Size Probability');
    set(gca,'Box','on','Layer','top'); 
end