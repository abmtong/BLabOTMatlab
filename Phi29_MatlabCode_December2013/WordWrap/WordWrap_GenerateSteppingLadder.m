function [Time Contour Dwell] = WordWrap_GenerateSteppingLadder(NumberOfBursts)
%
% USE: [Time Contour Dwell] = WordWrap_GenerateSteppingLadder()
%
% gheorghe chistol, 19 Feb 2013

    DwellMean                  = 0.15;  %in seconds
    DwellMeanStdFract          = 0.30; % as a fraction relative to DwellMean
    BurstMiniDwellMean         = 0.02; %in seconds
    BurstMiniDwellMeanStdFract = 0.40; %as a fraction
    BurstSizeMean              = 10; %in bp
    BurstSizeMeanStdFract      = 0.15; % as a fraction relative to BurstSizeMean
    SamplingFrequency          = 250; %in Hz
    if nargin==0
        NumberOfBursts = 10; %how many bursts to simulate
    end

    DwellList = []; %will have length N
    StepList  = []; %will have length N-1, there are one more dwells than steps
    
    for b = 1:NumberOfBursts
        %1. Get Dwell Duration
        CurrDwellDur = WordWrap_DrawValue(DwellMean,DwellMeanStdFract);
        %2. Get Burst Size
        CurrBurstSize = WordWrap_DrawValue(BurstSizeMean,BurstSizeMeanStdFract);
        %3. Get Bust fragmentation
        CurrBurstFrag = WordWrap_PartitionBurst(CurrBurstSize);
        %4. Get Mini-Dwell Duration during the Burst Size
        CurrBurstMiniDwellDur = [];
        for md = 1:length(CurrBurstFrag)-1
            %if there is only one fragment in the CurrBurstFrag, there are
            %no mini-dwells in the burst.
            CurrBurstMiniDwellDur(md) = WordWrap_DrawValue(BurstMiniDwellMean,BurstMiniDwellMeanStdFract);
        end
        
        % add the dwell and burst to the existing vector
        DwellList = [DwellList CurrDwellDur CurrBurstMiniDwellDur];
        StepList  = [StepList CurrBurstFrag];
    end
    %at the very end generate a regular dwell
    DwellList(end+1) = WordWrap_DrawValue(DwellMean,DwellMeanStdFract);
    
    % now generate the Time/Contour vector for this simulated trace
    Time = [];
    Contour = [];
    Dwell.Location = []; 
    Dwell.Duration = [];
    for d=1:length(DwellList)
        if d==1
            CurrLocation = 0;
            CurrTime = 0;
        else
            CurrLocation = Contour(end)-StepList(d-1);
            CurrTime = Time(end);
        end
        NumPoints = ceil(DwellList(d)*SamplingFrequency);
        Time = [Time CurrTime+(1:NumPoints)/SamplingFrequency];
        Contour = [Contour CurrLocation*ones(1,NumPoints)];
        Dwell.Location(d) = CurrLocation;
        Dwell.Duration(d) = DwellList(d);
    end
end