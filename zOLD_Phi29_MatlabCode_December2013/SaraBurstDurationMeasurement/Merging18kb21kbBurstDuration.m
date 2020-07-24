function Merging18kb21kbBurstDuration(Burst_18kb,Burst_21kb)
%
    FillingBins = [50:2.5:100]; %in percent
    Burst_18kb.Filling = (18000-Burst_18kb.Location)/19300*100;
    Burst_21kb.Filling = (21000-Burst_21kb.Location)/19300*100;
    Burst.Filling  = [Burst_18kb.Filling Burst_21kb.Filling];
    Burst.Duration = [Burst_18kb.Duration Burst_21kb.Duration];

    BurstDuration    = [];
    BurstDurationErr = [];
    for i = 1:length(FillingBins)-1
        KeepInd = Burst.Filling>FillingBins(i) & Burst.Filling<FillingBins(i+1);
        CurrData = Burst.Duration(KeepInd);
        BurstDuration(i)    = mean(CurrData);
        BurstDurationErr(i) = std(CurrData)/sqrt(length(CurrData));
    end
    MeanFilling = (FillingBins(1:end-1)+FillingBins(2:end))/2;
    figure;
    errorbar(MeanFilling,1000*BurstDuration,1000*BurstDurationErr,'^m');
    xlabel('Capsid Filling (%)');
    ylabel('Burst Duration (ms)');
        
end