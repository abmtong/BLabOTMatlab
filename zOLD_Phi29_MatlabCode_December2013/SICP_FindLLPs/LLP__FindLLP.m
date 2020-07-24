function LLP__FindLLP()
    % Use the SICP method to find dwells/pauses. In this version bursts are
    % assumed to be instantaneous. The focus is on long lived pauses, LLP.
    %
    % You will need:
    % 1) Processed Phage files (mat files)
    % 2) An index file with instructions: 070108N90 4 5 6 7 8 
    %    you can also specify to use all feedback cycles in a given trace:
    %    "070108N90 crop"
    %
    % USE: LLP__FindLLP()
    %
    % Gheorghe Chistol, 30 Nov 2012
    
    global analysisPath;

    %% Get Step-Finding Parameters
    Prompt = {'Data Acquisition Bandwidth (Hz)', 'Filter Bandwidth (Hz)',...
              'Penalty 1: Mean of the Variance in a Pause (bp^2)',...
              'Penalty 2: Variance of the Variance in a Pause (bp^2)',...
              'Penalty 3: Empirical Penalty Factor',...
              'Maximum Time in a Continuous Analysis Stretch (s)',...
              'Minimum distance between two dwells/pauses (bp)',...
              'Minimum duration of a dwell (s)'};
          
    Title            = 'Enter the Following Parameters'; Lines = 1;
    Default          = {'2500','100','2.24','0.91','1','10.00','2','0.02'};
    Answer           = inputdlg(Prompt, Title, Lines, Default);
    SampFreq         = str2num(Answer{1}); %#ok<*ST2NM> %sampling frequency
    Bandwidth        = str2num(Answer{2}); %the frequency to which raw data will be filtered
    AvgNum           = round(SampFreq/Bandwidth);  %filtering factor for filter-and-decimate
    E                = str2num(Answer{3}); % Mean of the variance in a pause (i.e. expected value)
    V                = str2num(Answer{4}); % Variance of the variance in a pause
    LongestTime      = str2num(Answer{6}); %longest amount of time in one analysis stretch
    MinStep          = str2num(Answer{7}); %if any dwells/pauses are closer than this, they should be merged together
    MinDuration      = str2num(Answer{8}); %min duration of a dwell
    
    PenaltyFactor.S0 = 2*E*(E^2/V+1); % for SICP
    PenaltyFactor.Nu = 2*E^2/V+4;     % for SICP
    PenaltyFactor.Penalty = str2num(Answer{5}); % Empyrical Penalty Factor
    PenaltyFactor.AvgNum  = AvgNum;             % the filtering factor, remember it just in case
    

    [IndexFile IndexFilePath] = uigetfile([ [analysisPath filesep] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
                    IndexFile = [IndexFilePath filesep IndexFile];
                     SaveFile = [IndexFile(1:end-4) '_FindLLP.mat']; %where the step-finding results will be saved
    
    if ~exist(IndexFile,'file') %if no files were selected or file doesn't exist
        disp('No Index File phage files were selected'); return;
    end
    
    [SelectedPhages SelectedFeedbackCycles CropStartTimes CropFinishTimes] = LLP_LoadPhageList(IndexFile); %loads the index of the sub-traces that are good

    %% Go Through Each Phage & Each Feedback Cycle and Find Steps
    for p=1:length(SelectedPhages) %p is the index of the "phage" 
        CurrentPhageName = ['phage' SelectedPhages{p}];
        CurrentPhageFile = [analysisPath filesep CurrentPhageName '.mat'];

        if ~exist(CurrentPhageFile,'file') %if the phage data file does not exist
            disp(['!!! Phage Data File does not exist: ' CurrentPhageFile]);
        else
            disp(['+ Analyzing Phage ' CurrentPhageFile]);
            load(CurrentPhageFile); PhageData = stepdata; clear stepdata; %calibrated data from the current trace

            % Run the Step Finding Routine for each Feedback Cycle of the phage trace
            for fc = 1:length(SelectedFeedbackCycles{p}) %fc is the index of the "FeedbackCycle"
                CurrentFeedbackCycle = SelectedFeedbackCycles{p}(fc);
                % If there exists a Crop-File, load it and trim the data in the current feedback cycle
                RawY   = PhageData.contour{CurrentFeedbackCycle}; %unfiltered raw data
                RawT   = PhageData.time{CurrentFeedbackCycle};
                RawF   = PhageData.force{CurrentFeedbackCycle};
                KeepInd = RawT>CropStartTimes(p) & RawT<CropFinishTimes(p); %use only data within the crop boundaries
                RawT = RawT(KeepInd);
                RawY = RawY(KeepInd);
                RawF = RawF(KeepInd);
                if range(RawT)<0.25 %the trace needs to have more than 0.25 sec worth of data 
                    disp(['! Feedback Cycle #' num2str(SelectedFeedbackCycles{p}(fc)) 'skipped due to insuficient data']);
                else
                    disp(['+ Analyzing Feedback Cycle ' num2str(CurrentFeedbackCycle)]);                 
                    NumSect = ceil(range(RawT/LongestTime)); %this can take too long to analyze, break it up %number of analysis sections that are needed
                    IndexFinish = round((1:1:NumSect)/NumSect*length(RawT));
                    IndexStart  = [1 IndexFinish(1:end-1)+1]; %where a section starts
                    FiltT = []; FiltY = []; FiltF = []; %vector of filtered data corresponding to this feedback cycle
                    for s = 1:length(IndexStart) %run a separate cycle for each analysis section                        
                        tempRawT = RawT(IndexStart(s):IndexFinish(s));
                        tempRawY = RawY(IndexStart(s):IndexFinish(s));
                        tempRawF = RawF(IndexStart(s):IndexFinish(s));
                        [DwellInd{p}{fc}{s} FinalDwells{p}{fc}{s} tempFiltT tempFiltY tempFiltF] = ...
                            LLP_HelperModule(tempRawT,tempRawY,tempRawF,PenaltyFactor,AvgNum,Bandwidth,CurrentPhageName,CurrentPhageFile,CurrentFeedbackCycle,analysisPath,s,MinStep,MinDuration); %#ok<*AGROW>                       
                        FiltT = [FiltT tempFiltT]; %add the filtered data corresponding to this trace section
                        FiltY = [FiltY tempFiltY];
                        FiltF = [FiltF tempFiltF];
                    end
                    
                    if length(IndexStart)>1
                        while length(DwellInd{p}{fc})>1 %merge the DwellInd if there are more than one sections
                            IndexOffset = DwellInd{p}{fc}{1}(end).Finish-1; %offset of index
                            for d=1:length(DwellInd{p}{fc}{2}) %merge DwellInd{p}{fc}(1) and DwellInd{p}{fc}(2) 
                                DwellInd{p}{fc}{2}(d).Start  = DwellInd{p}{fc}{2}(d).Start+IndexOffset; 
                                DwellInd{p}{fc}{2}(d).Finish = DwellInd{p}{fc}{2}(d).Finish+IndexOffset;
                            end
                            DwellInd{p}{fc}{1} = [DwellInd{p}{fc}{1} DwellInd{p}{fc}{2}]; %merge
                            DwellInd{p}{fc}(2) = [];                            
                        end
                        DwellInd{p}{fc}{1}        = LLP_HelperModuleConsolidateDwells(DwellInd{p}{fc}{1},Bandwidth,FiltY,MinStep,MinDuration);
                        [FinalDwells{p}{fc}{1} ~] = LLP_HelperModuleFinalDwells(DwellInd{p}{fc}{1},FiltT,FiltY,FiltF,CurrentPhageFile,CurrentFeedbackCycle,Bandwidth);
                        LLP_PlotFinalResults(RawT,RawY,FiltT,FiltY,FinalDwells{p}{fc}{1},FinalDwells{p}{fc}{1},analysisPath,CurrentPhageName,NaN); %instead of specifying section number, give NaN
                    end
                end
            end
        end
    end

    save(SaveFile,'FinalDwells');
    disp(['Saved stepping data to ' SaveFile]);
    disp('--------------------------------------------------------');
end