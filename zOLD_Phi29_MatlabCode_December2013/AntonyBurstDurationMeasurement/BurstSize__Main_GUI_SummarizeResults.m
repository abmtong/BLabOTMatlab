function [Burst Dwell] = BurstSize__Main_GUI_SummarizeResults()
% Select a bunch of burst duration analysis files and organize the results
%USE: [Burst Dwell] = BurstSize__Main_GUI_SummarizeResults()
%
% Gheorghe Chistol, 25 feb 2013
    global analysisPath;
    [FileName FilePath] = uigetfile([ [analysisPath filesep 'SaraBurstDurationAnalysis' filesep] 'BurstDur*.mat'], 'Please select the Burst Duration Results File','MultiSelect','on');

    if ~iscell(FileName)
        temp = FileName; clear FileName; FileName{1} = temp; clear temp;
    end

    Burst.Size     = [];
    Burst.Duration = [];
    Burst.Location = [];
    Burst.Force    = [];
    
    Dwell.Duration   = [];
    Dwell.Location   = [];
    Dwell.Force      = [];
    Dwell.BurstAfter = [];
    
    for f = 1:length(FileName)
        clear Trace;
        load([FilePath filesep FileName{f}]);
        if isfield(Trace,'Dwells')
            if isfield(Trace.Dwells,'ATPBindingDwells')
                %organize the Burst structure
                tempSize       = -diff(Trace.Dwells.ATPBindingDwells.Dwell.MeanLocation);
                Burst.Size     = [Burst.Size tempSize];
                Burst.Duration = [Burst.Duration Trace.Dwells.ATPBindingDwells.Burst.Duration    ];
                Burst.Location = [Burst.Location Trace.Dwells.ATPBindingDwells.Burst.MeanLocation];
                Burst.Force    = [Burst.Force    Trace.Dwells.ATPBindingDwells.Burst.MeanForce   ];
                
                %organize the Dwell structure
                Dwell.Duration   = [Dwell.Duration   Trace.Dwells.ATPBindingDwells.Dwell.Duration    ];
                Dwell.Location   = [Dwell.Location   Trace.Dwells.ATPBindingDwells.Dwell.MeanLocation];
                Dwell.Force      = [Dwell.Force      Trace.Dwells.ATPBindingDwells.Dwell.MeanForce   ];
                Dwell.BurstAfter = [Dwell.BurstAfter tempSize NaN];
            end
        end
    end
    
    Bins = [5:2:25];
    BurstDuration    = [];
    BurstDurationStd = [];
    for b = 1:length(Bins)-1
        KeepInd = Burst.Force>Bins(b) & Burst.Force<Bins(b+1);
        CurrData = Burst.Duration(KeepInd);
        BurstDuration(b) = mean(CurrData);
        BurstDurationStd(b) = std(CurrData)/sqrt(length(CurrData));
    end
    MeanF = (Bins(1:end-1)+Bins(2:end))/2;
    figure;
    errorbar(MeanF,1000*BurstDuration,1000*BurstDurationStd,'ob');
    xlabel('Force (pN)');
    ylabel('Burst Duration (ms)');
    
    DwellDuration    = [];
    DwellDurationStd = [];
    for b = 1:length(Bins)-1
        KeepInd = Dwell.Force>Bins(b) & Dwell.Force<Bins(b+1);
        CurrData = Dwell.Duration(KeepInd);
        DwellDuration(b) = mean(CurrData);
        DwellDurationStd(b) = std(CurrData)/sqrt(length(CurrData));
    end
    MeanF = (Bins(1:end-1)+Bins(2:end))/2;
    figure;
    errorbar(MeanF,1000*DwellDuration,1000*DwellDurationStd,'or');
    xlabel('Force (pN)');
    ylabel('Dwell Duration (ms)');
        
    Location = 0:1000:5000;
    BurstDuration = [];
    BurstDurationErr = [];
    for i = 1:length(Location)-1
        KeepInd = Burst.Location>Location(i) & Burst.Location<Location(i+1);
        CurrData = Burst.Duration(KeepInd);
        BurstDuration(i)    = mean(CurrData);
        BurstDurationErr(i) = std(CurrData)/sqrt(length(CurrData));
    end
    MeanL = (Location(1:end-1)+Location(2:end))/2;
    figure;
    errorbar((18000-MeanL)/19300*100,1000*BurstDuration,1000*BurstDurationErr,'^k');
    xlabel('Capsid Filling (%)');
    ylabel('Burst Duration (ms)');
        
end