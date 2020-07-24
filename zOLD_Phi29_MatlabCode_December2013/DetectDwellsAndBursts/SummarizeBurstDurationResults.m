function DwellDuration = SummarizeBurstDurationResults()
% load a tTest_Main results file
% compute the mean burst duration
%
% Gheorghe Chistol

    BurstMin = 8;
    BurstMax = 11;
    global analysisPath;
    [file folder] = uigetfile([ [analysisPath filesep] '*Results.mat'], 'Please select the Results File','MultiSelect', 'off');

    clear Results; %just to make sure
    if exist([folder filesep file],'file')
        load([folder filesep file]);
    end

    % Results(i)
    %         PhageFile: '080411N42'
    %     FeedbackCycle: 37
    %         BasicData: [1x1 struct]
    %      DwellsBursts: [1x1 struct]

    %% Summarize
    BurstDuration = [];
    DwellDuration = [];
    
    for r = 1:length(Results)
        Size  = Results(r).DwellsBursts.BurstSizeBp;
        Burst = Results(r).DwellsBursts.BurstDuration;
        Dwell = Results(r).DwellsBursts.DwellDuration;
        
        KeepInd = Size>BurstMin & Size<BurstMax;
        BurstDuration = [BurstDuration Burst(KeepInd)];
        DwellDuration = [DwellDuration Dwell(KeepInd)];
    end
end