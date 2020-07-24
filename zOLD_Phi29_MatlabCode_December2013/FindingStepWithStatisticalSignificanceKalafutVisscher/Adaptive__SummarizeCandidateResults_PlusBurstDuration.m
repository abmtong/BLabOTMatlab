function [FCSize Dwell Burst] = Adaptive__SummarizeCandidateResults_PlusBurstDuration()
    global analysisPath;
    [ResultsFile ResultsFilePath] = uigetfile([ [analysisPath filesep] 'PhageList_BestPwdScore_*.mat'], 'Please select the Step-Finding Results File','MultiSelect','on');

    if ~iscell(ResultsFile)
        temp = ResultsFile; clear ResultsFile; ResultsFile{1} = temp; clear temp;
    end
    
    disp(ResultsFilePath)
    
    Dwell.Duration       = [];
    Dwell.Location       = [];
    %Dwell.SizeStepBefore = [];
    %Dwell.SizeStepAfter  = [];

    Burst.Size     = [];
    Burst.Duration = [];
    FCSize         = [];
    %Burst.Duration = [];
    %Step.Size                = [];
    %Step.Location            = [];
    %Step.DurationDwellBefore = [];
    %Step.DurationDwellAfter  = [];
    
    counter=0;
    for FileInd = 1:length(ResultsFile)
        clear BandwidthList BestBandwidth FinalDwells FinalDwellsValidated RecordOfValidatedDwells ProposedDwells;
        A=load([ResultsFilePath filesep ResultsFile{FileInd}]);
        %FinalDwellsValidated{PhageIndex}{FeedbackCycleIndex}{SegmentIndex}{BandwidthIndex}
        %BestBandwisth{PhageIndex}{FeedbackCycleIndex}{SegmentIndex}
        disp(A);
        FinalDwells=A.FinalDwells;
        BestBandwidth=A.BestBandwidth;
        MinFraction = 0.25; %at least 50% of the feedback cycle should contain valid dwells
        for p = 1:length(FinalDwells) %p indexes the Phage file
            for fc = 1:length(FinalDwells{p}) %fc indexes the feedback cycle
                for s = 1:length(FinalDwells{p}{fc})
                    BestIndex = BestBandwidth{p}{fc}{s}.Index;
                    CurrDwellStructure = FinalDwells{p}{fc}{s}{BestIndex};
                    Dwell.Location=[Dwell.Location CurrDwellStructure.DwellLocation];
                    counter=0;
                        for d = 2:length(CurrDwellStructure.DwellLocation)-1                            
                            Burst.Size=[Burst.Size CurrDwellStructure.DwellLocation(d-1)-CurrDwellStructure.DwellLocation(d)];
                            if isfield(CurrDwellStructure, 'BurstDuration')
                            Burst.Duration = [Burst.Duration CurrDwellStructure.BurstDuration(d)];
                            end
                            Dwell.Location=[Dwell.Location CurrDwellStructure.DwellLocation(d)];
                            %Duration=;
                            Dwell.Duration=[Dwell.Duration CurrDwellStructure.FinishTime(d)-CurrDwellStructure.StartTime(d)];
                            counter=counter+1;
                        end
                       FCSize=[FCSize counter];
                        %if a burst is to be valid, it needs to have a dwell before and a dwell after
                    %end
                end
            end
        end
    end
end