function PlotData = uPlotBurstSizeVsFilling(Result,SelectedColor)
%
% USE: uPlotBurstSizeVsFilling(Result,SelectedColor)

    MaxBurst = 15;
    MinBurst = 5;
    %Bins = [0 500 1000 1500 2000 4000]; %6kb
    %Bins = [0 1000 2000 3000 4000 6000]; %18kb
    %Bins = [0 1000 2000 3000 4000 5000]; %21kb
    Bins = [0 6000 14.5e3 16e3 17.5e3 19e3 21e3];
    BurstLocation = Result.BurstLocation;
    BurstSize     = Result.BurstSize;
    %yerr = Result.BurstSizeErr;
    KeepInd       = BurstSize>MinBurst & BurstSize<MaxBurst;
    BurstSize     = BurstSize(KeepInd);
    BurstLocation = BurstLocation(KeepInd);
    
    Size.Mean        = nan(1,length(Bins)-1);
    Size.UpperLim    = nan(1,length(Bins)-1);
    Size.LowerLim    = nan(1,length(Bins)-1);
    Size.MinLocation = nan(1,length(Bins)-1);
    Size.MaxLocation = nan(1,length(Bins)-1);
    Size.BurstNumber = nan(1,length(Bins)-1);
    
    for b = 1:length(Bins)-1
        MinLocation = Bins(b);
        MaxLocation = Bins(b+1);
        Ind = BurstLocation>MinLocation & BurstLocation<MaxLocation;
        temp = BurstSize(Ind);
        if length(temp)>5;
            Mean = uComputeMeanConfidenceInterval(temp,1000,0.95);
            Size.Mean(b)        = Mean(2);
            Size.LowerLim(b)    = Mean(1);
            Size.UpperLim(b)    = Mean(3);
            Size.MinLocation(b) = MinLocation;
            Size.MaxLocation(b) = MaxLocation;
            Size.BurstNumber(b) = length(temp);
            Size.BurstStd(b) = std(temp);
        end
    end
    figure; hold on;
    plot(BurstLocation,BurstSize,'.','Color',0.9*[1 1 1]);
    
    PlotData.BurstAvg = [];
    PlotData.BurstStd = [];
    PlotData.BurstNum = [];
    PlotData.Filling  = [];
    PlotData.UpperErr = [];
    PlotData.LowerErr = [];
    PlotData.LeftErr  = [];
    PlotData.RightErr = [];
    
    
    
    for b = 1:length(Size.Mean)
        x = [Size.MinLocation(b)*[1 1] Size.MaxLocation(b)*[1 1]];
        y = [Size.LowerLim(b)    Size.UpperLim(b)*[1 1]    Size.LowerLim(b)   ];
        h = patch(x,y,'k');
        set(h,'FaceColor',SelectedColor,'FaceAlpha',0.3,'LineStyle','none');
        plot([Size.MinLocation(b) Size.MaxLocation(b)],Size.Mean(b)*[1 1],'-','Color',SelectedColor);
        x = Size.MinLocation(b)+200;
        y = Size.Mean(b)+0.05;
        %x = Size.MinLocation(b)+50;
        %y = Size.LowerLim(b)-0.3;
        NumBurst = sprintf('%3d',Size.BurstNumber(b));
        h = text(x,y,NumBurst); set(h,'Color',SelectedColor);
        PlotData.Filling(b)  = mean([Size.MinLocation(b) Size.MaxLocation(b)]);
        PlotData.LeftErr(b)  = abs(PlotData.Filling(b)-Size.MinLocation(b));
        PlotData.RightErr(b) = abs(PlotData.Filling(b)-Size.MaxLocation(b));
        PlotData.BurstAvg(b) = Size.Mean(b);
        PlotData.UpperErr(b) = abs(PlotData.BurstAvg(b)-Size.UpperLim(b));
        PlotData.LowerErr(b) = abs(PlotData.BurstAvg(b)-Size.LowerLim(b));
        PlotData.BurstNum(b) = Size.BurstNumber(b); 
        PlotData.BurstStd(b) = Size.BurstStd(b);
    end
        
    %set(gca,'YLim',[0 MaxBurst]);
    %set(gca,'XLim',[min(Bins) max(Bins)]);
    xlabel('DNA Tether Length (bp)');
    ylabel('Mean Burst Size (bp)');
    
    %now plot just the error-bars
    %Convert x axis to filling
    Genome = 19300;
    PlotData.Filling = PlotData.Filling/Genome*100; 
    PlotData.LeftErr = PlotData.LeftErr/Genome*100;
    PlotData.RightErr = PlotData.RightErr/Genome*100;
    
    figure; hold on
    errorbar(PlotData.Filling,PlotData.BurstAvg,PlotData.LowerErr,PlotData.UpperErr,'.b');
    herrorbar(PlotData.Filling,PlotData.BurstAvg,PlotData.LeftErr,PlotData.RightErr,'.b');
    set(gca,'Box','on');
end