function [FCSize Dwell Burst] = Adaptive__SummarizeResults_PlusBurstDuration()
    global analysisPath;
    [ResultsFile ResultsFilePath] = uigetfile([ [analysisPath filesep] 'BestPwdScore_*.mat'], 'Please select the Step-Finding Results File','MultiSelect','on');

    if ~iscell(ResultsFile)
        temp = ResultsFile; clear ResultsFile; ResultsFile{1} = temp; clear temp;
    end
    
    Dwell.Duration       = [];
    Dwell.Location       = [];
    %Dwell.SizeStepBefore = [];
    %Dwell.SizeStepAfter  = [];

    Burst.Size     = [];
    FCSize         = [];
    %Burst.Duration = [];
    %Step.Size                = [];
    %Step.Location            = [];
    %Step.DurationDwellBefore = [];
    %Step.DurationDwellAfter  = [];
    
    counter=0;
    for FileInd = 1:length(ResultsFile)
        clear BandwidthList BestBandwidth FinalDwells FinalDwellsValidated RecordOfValidatedDwells ProposedDwells;
        load([ResultsFilePath filesep ResultsFile{FileInd}]);
        %FinalDwellsValidated{PhageIndex}{FeedbackCycleIndex}{SegmentIndex}{BandwidthIndex}
        %BestBandwisth{PhageIndex}{FeedbackCycleIndex}{SegmentIndex}

        MinFraction = 0.25; %at least 50% of the feedback cycle should contain valid dwells
        for p = 1:length(ProposedDwells) %p indexes the Phage
            for fc = 1:length(ProposedDwells{p}) %fc indexes the feedback cycle
                for s = 1:length(ProposedDwells{p}{fc})
                    BestIndex = BestBandwidth{p}{fc}{s}.Index;
                    CurrDwellStructure = ProposedDwells{p}{fc}{s}{BestIndex}{1};
                    Dwell.Location=[Dwell.Location CurrDwellStructure(1).DwellLocation];
                    counter=0;
                        for d = 2:length(CurrDwellStructure)-1                            
                            Burst.Size=[Burst.Size CurrDwellStructure(d-1).DwellLocation-CurrDwellStructure(d).DwellLocation];
                            Dwell.Location=[Dwell.Location CurrDwellStructure(d).DwellLocation];
                            Dwell.Duration=[Dwell.Duration CurrDwellStructure(d).FinishTime-CurrDwellStructure(d).StartTime];
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