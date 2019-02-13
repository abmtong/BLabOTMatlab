function DwellsBursts = tTest_FindDwellsBursts(Data,tTestThr)
% Data.Time
% Data.Contour
% Data.FilteredTime
% Data.FilteredContour
% Data.FilteringFactor
% Data.t
% Data.sgn
%
% DwellsBursts.DwellStartInd  = DwellStartInd;
% DwellsBursts.DwellFinishInd = DwellFinishInd;
% DwellsBursts.DwellMean      = DwellMean;
% DwellsBursts.DwellStd       = DwellStd;
% DwellsBursts.DwellNpts      = DwellNpts;
% DwellsBursts.DwellDuration  = DwellDuration;
% DwellsBursts.BurstStartInd  = BurstStartInd;
% DwellsBursts.BurstFinishInd = BurstFinishInd;
% DwellsBursts.BurstMean      = BurstMean;
% DwellsBursts.BurstStd       = BurstStd;
% DwellsBursts.BurstNpts      = BurstNpts;
% DwellsBursts.BurstDuration  = BurstDuration;
% DwellsBursts.LadderTime     = LadderTime;
% DwellsBursts.LadderContour  = LadderContour;
%
%USE: DwellsBursts = tTest_FindDwellsBursts(Data,tTestThr)

    % Detect Bursts
    % a burst is whatever falls below the tTestThr line
    IsBurst = (Data.sgn <= tTestThr);

    % go through the data and mark the continuous stretches of 
    % IsBurst == 1 as bursts

    Signal = diff([0 IsBurst]); %the zero helps keep the vector size the same
    % whenever Signal==1  we have the start of a burst there
    % whenever Signal==-1 we have the finish of a burst there
    BurstStartInd  = find(Signal==1);
    BurstFinishInd = find(Signal==-1);
    if IsBurst(end)==1
        BurstFinishInd = [BurstFinishInd length(IsBurst)]; %the last burst ends where the trace ends
    end
    
    DwellStartInd  = NaN*ones(1,length(BurstStartInd)+1); %by default we assume that the trace starts with a dwell and ends with a dwell
    DwellFinishInd = NaN*ones(1,length(BurstStartInd)+1);
    %keyboard
    %we can't have a trace that begins with a burst, so we'll get rid of it
    if IsBurst(1)==1
        DwellStartInd(1)  = []; DwellFinishInd(1) = []; %remove a dwell entry
        DwellStartInd(1)  = BurstFinishInd(1); %first valid dwell starts where the first burst finishes
        DwellFinishInd(1) = BurstStartInd(2);  %first valid dwell ends where the second burst starts
        BurstStartInd(1)  = []; BurstFinishInd(1) = []; %remove the current burst entry
    else
        DwellStartInd(1)  = 1; %in normal circumstances the first dwell starts at 1
        DwellFinishInd(1) = BurstStartInd(1);  %the first dwell ends where the first burst starts
    end

    %we can't have a trace ending with a burst, so we'll get rid of it
    if IsBurst(end)==1
        DwellStartInd(end)  = []; DwellFinishInd(end) = []; %remove a dwell entry
        DwellStartInd(end)  = BurstFinishInd(end-1); %the last valid dwell starts where the second to last burst ends
        DwellFinishInd(end) = BurstStartInd(end);    %the last valid dwell ends where the last burst starts
        BurstStartInd(end)  = []; BurstFinishInd(end) = []; %remove the last burst, since it's invalid
    else
        DwellStartInd(end)  = BurstFinishInd(end); %in normal circumstances the last dwell starts where the last burst ends
        DwellFinishInd(end) = length(Data.sgn);    %the last dwell ends at the end of the data vector\
    end
    
    for d = 2:length(DwellStartInd)-1 %the first and the last dwells have been taken care of
        DwellStartInd(d)  = BurstFinishInd(d-1);
        DwellFinishInd(d) = BurstStartInd(d);
    end
    %keyboard
    %% Determine the Mean of each Dwell, Duration of Each Dwell
    for d = 1:length(DwellStartInd)
        ind              = DwellStartInd(d):DwellFinishInd(d);
        DwellMean(d)     = mean(Data.FilteredContour(ind));
        DwellStd(d)      = std(Data.FilteredContour(ind));
        DwellNpts(d)     = length(ind);
        DwellDuration(d) = range(Data.FilteredTime(ind));
    end

    % Determine the Duration of Each Burst
    for b = 1:length(BurstStartInd)
        ind              = BurstStartInd(b):BurstFinishInd(b);
        BurstMean(b)     = mean(Data.FilteredContour(ind));
        BurstStd(b)      = std(Data.FilteredContour(ind));
        BurstNpts(b)     = length(ind);
        BurstDuration(b) = range(Data.FilteredTime(ind));
        BurstSizeBp(b)   = DwellMean(b)-DwellMean(b+1);
    end

    % Construct a ladder of Dwells-Bursts
    LadderTime    = NaN*ones(1,2*length(DwellMean));
    LadderContour = NaN*ones(1,2*length(DwellMean));

    for d=1:length(DwellMean)
        LadderTime(2*d-1) = Data.FilteredTime(DwellStartInd(d));
        LadderTime(2*d)   = Data.FilteredTime(DwellFinishInd(d));
        LadderContour(2*d-1) = DwellMean(d); 
        LadderContour(2*d)   = DwellMean(d);
    end

    DwellsBursts.DwellStartInd  = DwellStartInd;
    DwellsBursts.DwellFinishInd = DwellFinishInd;
    DwellsBursts.DwellMean      = DwellMean;
    DwellsBursts.DwellStd       = DwellStd;
    DwellsBursts.DwellNpts      = DwellNpts;
    DwellsBursts.DwellDuration  = DwellDuration;
    DwellsBursts.BurstStartInd  = BurstStartInd;
    DwellsBursts.BurstFinishInd = BurstFinishInd;
    DwellsBursts.BurstMean      = BurstMean;
    DwellsBursts.BurstSizeBp    = BurstSizeBp;
    DwellsBursts.BurstStd       = BurstStd;
    DwellsBursts.BurstNpts      = BurstNpts;
    DwellsBursts.BurstDuration  = BurstDuration;
    DwellsBursts.LadderTime     = LadderTime;
    DwellsBursts.LadderContour  = LadderContour;

    % if two bursts are very close, closer than CloserN points, the bursts
    % are merged. We're talking about only a few points, 2-3
    % CloseN = 3;
end