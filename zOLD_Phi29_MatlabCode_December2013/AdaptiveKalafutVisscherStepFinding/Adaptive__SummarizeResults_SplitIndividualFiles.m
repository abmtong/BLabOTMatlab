function [MatD MatB] = Adaptive__SummarizeResults_SplitIndividualFiles()
    global analysisPath;
    [ResultsFile ResultsFilePath] = uigetfile([ [analysisPath filesep] 'BestPwdScore_*.mat'], 'Please select the Step-Finding Results File','MultiSelect','on');

    if ~iscell(ResultsFile)
        temp = ResultsFile; clear ResultsFile; ResultsFile{1} = temp; clear temp;
    end
    
    MatrixD=[];
    MatrixB=[];
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
        for p = 1:length(FinalDwellsValidated) %p indexes the Phage
            Dwell.Duration       = 0;
            Dwell.Location       = 0;
             Dwell.SizeStepBefore = 0;
              Dwell.SizeStepAfter  = 0;

               Burst.Size     = 0;
               Burst.Duration = 0;
               
               counter=counter+1;
            for fc = 1:length(FinalDwellsValidated{p}) %fc indexes the feedback cycle
                for s = 1:length(FinalDwellsValidated{p}{fc})
                    BestIndex = BestBandwidth{p}{fc}{s}.Index;
                    FractionValid = BestBandwidth{p}{fc}{s}.FractionValid;

                    if FractionValid>MinFraction %only use the dwells/bursts from feedback cycles with lots of good data
                        CurrDwells = FinalDwellsValidated{p}{fc}{s}{BestIndex};
                        if isfield(CurrDwells,'BurstDuration') 
                            GoodBurstInd   = ~isnan(CurrDwells.BurstDuration);
                            Burst.Size     = [Burst.Size CurrDwells.StepSize(GoodBurstInd)];
                            Burst.Duration = [Burst.Duration CurrDwells.BurstDuration(GoodBurstInd)];
                        end
                        
                        %if a dwell is to be valid, it needs to have a burst before and a burst after
                        for d = 2:length(CurrDwells.DwellTime)-1 
                            %the very first dwell and the very last dwell are automatically not of interest

                            %make sure the current dwell and the previous dwell are consecutive in time
                            IsPrevConsecutive = ((CurrDwells.Finish(d-1)+1) == CurrDwells.Start(d));
                            %make sure the current dwell and the following dwell are also consecutive in time
                            IsNextConsecutive = ((CurrDwells.Finish(d)+1) == CurrDwells.Start(d+1));

                            if IsPrevConsecutive && IsNextConsecutive %this is a valid dwell
                                %CurrDwells.DwellTime(d) is followed by CurrDwells.StepSize(d)
                                Dwell.Duration       = [Dwell.Duration CurrDwells.DwellTime(d)];
                                Dwell.Location       = [Dwell.Location CurrDwells.DwellLocation(d)];
                                Dwell.SizeStepBefore = [Dwell.SizeStepBefore CurrDwells.StepSize(d-1)];
                                Dwell.SizeStepAfter  = [Dwell.SizeStepAfter   CurrDwells.StepSize(d)];
                            end
                        end
                        %if a burst is to be valid, it needs to have a dwell before and a dwell after
                    end
                end
            end
            MatB(counter)=Burst;
            MatD(counter)=Dwell;
        end  
    end
end