function [Ordered  Dwell Index] = Adaptive_RecoverDwellCandidateAndIndex()
    global analysisPath; % reads where are the files
    [ResultsFile ResultsFilePath] = uigetfile([ [analysisPath filesep] 'BestPwdScore_*.mat'], 'Please select the Step-Finding Results File','MultiSelect','on');
    % Loads only the very best traces with a good PWD contrast
    if ~iscell(ResultsFile)
        temp = ResultsFile; clear ResultsFile; ResultsFile{1} = temp; clear temp;
    end
    
    % Initializes these two arrays
    Ordered.Dwells=[];
    Ordered.Index=[];
    
    % goes through each file and each feedback cycle
    for FileInd = 1:length(ResultsFile)
        clear BandwidthList BestBandwidth FinalDwells FinalDwellsValidated RecordOfValidatedDwells ProposedDwells;
        load([ResultsFilePath filesep ResultsFile{FileInd}]);
        %FinalDwellsValidated{PhageIndex}{FeedbackCycleIndex}{SegmentIndex}{BandwidthIndex}
        %BestBandwisth{PhageIndex}{FeedbackCycleIndex}{SegmentIndex}
       
        MinFraction = 0.10;
        for p = 1:length(ProposedDwells) %p indexes the Phage
            for fc = 1:length(ProposedDwells{p}) %fc indexes the feedback cycle
                for s = 1:length(ProposedDwells{p}{fc})
                    BestIndex = BestBandwidth{p}{fc}{s}.Index; % selects the best bandwidth for each feedback cycle
                    FractionValid = BestBandwidth{p}{fc}{s}.FractionValid; % this defines the amount of validated data that each trace contains
                    if FractionValid>MinFraction %only use the dwells/bursts from feedback cycles with lots of good data
                        Dwell = ProposedDwells{p}{fc}{s}{BestIndex}; %Recovers Dwells with from the right bandwidth
                        Dwell=Dwell{1}; % just changes the type of element.
                        Index = RecordOfValidatedDwells{p}{fc}{s}{BestIndex}; %This index contains which traces where validated and which ones did not
                        Index=Index{1}; % just changes the type of element.
                         if isfield(Dwell,'DwellLocation') 
                            %display('entered')
                            Ordered.Dwells     = [Ordered.Dwells     Dwell.DwellLocation]; % saves the dwells in one single vector
                            Ordered.Index = [Ordered.Index Index]; % saves the dwell indez in one single vector
                        end
                    end
                end
            end  
        end    
    end
end