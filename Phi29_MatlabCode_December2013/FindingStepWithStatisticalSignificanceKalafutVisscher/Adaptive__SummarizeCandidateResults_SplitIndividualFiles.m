function [MatFCSize MatD MatB] = Adaptive__SummarizeCandidateResults_SplitIndividualFiles()
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
        load([ResultsFilePath filesep ResultsFile{FileInd}]);
        %FinalDwellsValidated{PhageIndex}{FeedbackCycleIndex}{SegmentIndex}{BandwidthIndex}
        %BestBandwisth{PhageIndex}{FeedbackCycleIndex}{SegmentIndex}

        MinFraction = 0.25; %at least 50% of the feedback cycle should contain valid dwells
        for p = 1:length(FinalDwells) %p indexes the Phage
            Dwell.Duration       = 0;
            Dwell.Location       = 0;
            Burst.Size           = 0;
            FCSize=0;
            for fc = 1:length(FinalDwells{p}) %fc indexes the feedback cycle
                for s = 1:length(FinalDwells{p}{fc})
                    BestIndex = BestBandwidth{p}{fc}{s}.Index;
                    CurrDwellStructure = FinalDwells{p}{fc}{s}{BestIndex};
                    Dwell.Location=[Dwell.Location CurrDwellStructure.DwellLocation];
                    counter=0;
                        for d = 2:length(CurrDwellStructure.DwellLocation)-1                            
                            Burst.Size=[Burst.Size CurrDwellStructure.DwellLocation(d-1)-CurrDwellStructure.DwellLocation(d)];
                            Burst.Duration = [Burst.Duration CurrDwellStructure.BurstDuration(d)];
                            Dwell.Location=[Dwell.Location CurrDwellStructure.DwellLocation(d)];
                            Dwell.Duration=[Dwell.Duration CurrDwellStructure.FinishTime(d)-CurrDwellStructure.StartTime(d)];
                            counter=counter+1;
                        end
                        FCSize=[FCSize counter];
                        %if a burst is to be valid, it needs to have a dwell before and a dwell after
                    %end
                end
            end
            MatFCSize{p}=FCSize;
            MatD(p)=Dwell;
            MatB(p)=Burst;
        end
    end
end