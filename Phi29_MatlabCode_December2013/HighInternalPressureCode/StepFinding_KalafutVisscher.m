function StepFinding_KalafutVisscher()
    % This function finds steps using the Schwartz information Criterion method
    % described by Kalafut&Visscher. I have now incorporated dwell validation
    % using the side-view histogram (actually, an adaptive kernel density)
    %
    % You will need:
    % 1) Processed Phage files (mat files)
    % 2) An index file with instructions: 070108N90 4 5 6 7 8 
    %
    % USE: StepFinding_KalafutVisscher()
    %
    % Gheorghe Chistol, 30 Jun 2011

    %% Set the Analysis Path and the path for the Kalafut-Visscher method
    addpath([pwd filesep 'KalafutVisscher_StepFinding' filesep], '-end'); %where the KV scripts are located
    global analysisPath;
    if isempty(analysisPath)
        disp('analysisPath not defined. Use "SetAnalysisPath" to define it'); return;
    end

    %% Get Step-Finding Parameters
    Prompt = {'Data Acquisition Bandwidth (Hz)', 'KV Filter Bandwidth (Hz)', 'Step Penalty Factor (3-5 works best)',...
              'Maximum Separation Between Peak and Dwell Candidate(1-2bp)' , 'Contrast Threshold for Histogram Peak Validation(2-3)'};
          
    Title         = 'Enter the Following Parameters'; Lines = 1;
    Default       = {'2500','250','5','2','1.5'};
    Answer        = inputdlg(Prompt, Title, Lines, Default);
    SampFreq      = str2num(Answer{1}); %#ok<*ST2NM> %sampling frequency
    Bandwidth     = str2num(Answer{2}); %desired bandwidth after filtering, has to be an integer
    PenaltyFactor = str2num(Answer{3}); %penalty factor, 1 is the default for SIC, but larger penalties dicourage overfitting
    MaxSeparation = str2num(Answer{4}); %the peak shouldn't be any further than that from a candidate dwell location
    ContrastThr   = str2num(Answer{5}); %contrast threshold for ksdensity peak validation

    %% Load the Index File
    [IndexFile IndexFilePath] = uigetfile([ [analysisPath filesep] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
    IndexFile                 = [IndexFilePath filesep IndexFile];
    SaveFile                  = [IndexFile(1:end-4) '_ResultsKV.mat']; %where the step-finding results will be saved
    
    if ~exist(IndexFile,'file') %if no files were selected or file doesn't exist
        disp('No Index File phage files were selected'); return;
    end
    
    [SelectedPhages SelectedFeedbackCycles] = LoadPhageList(IndexFile); %loads the index of the sub-traces that are good

    %% Go Through Each Phage & Each Feedback Cycle and Find Steps
    for p=1:length(SelectedPhages) %index p stands for "phage" 
        CurrentPhageFileName = [analysisPath filesep 'phage' SelectedPhages{p} '.mat'];

        if ~exist(CurrentPhageFileName,'file') %if the phage data file does not exist
            disp(['!!! Phage Data File does not exist: ' CurrentPhageFileName]);
        else
            disp(['+ Analyzing Phage ' CurrentPhageFileName]);
            load(CurrentPhageFileName);
            PhageData = stepdata; clear stepdata; %calibrated data from the current trace

            % Run the Step Finding Routine for each Feedback Cycle of the phage trace
            for fc = 1:length(SelectedFeedbackCycles{p}) %index fc stands for "FeedbackCycle"
                % If there exists a Crop-File, load it and trim the data in the current feedback cycle
                % !!!!!!
                RawY   = PhageData.contour{SelectedFeedbackCycles{p}(fc)}; %unfiltered raw data
                RawT   = PhageData.time{SelectedFeedbackCycles{p}(fc)};
                AvgNum = round(SampFreq/Bandwidth);  %filtering factor for filter-and-decimate
                FiltY  = FilterAndDecimate(RawY, AvgNum);
                FiltT  = FilterAndDecimate(RawT, AvgNum);

                if range(RawT)<0.5 %the trace needs to have more than 0.5sec worth of data 
                    disp(['! Feedback Cycle #' num2str(SelectedFeedbackCycles{p}(fc)) 'skipped due to insuficient data']);
                else
                    CurrentFeedbackCycle = SelectedFeedbackCycles{p}(fc);
                    disp(['+ Analyzing Feedback Cycle ' num2str(CurrentFeedbackCycle)]);
                    PhageData.contourFiltered{CurrentFeedbackCycle} = FiltY;
                    PhageData.timeFiltered{CurrentFeedbackCycle}    = FiltT;
                    
                    %we use the Schwartz Information Criterion to identify
                    %dwell candidates, which will later go through a
                    %validation procedure based on the side-view histogram
                    DwellInd = KV_FindSteps(FiltY,PenaltyFactor);

                    %We can'd do side-histogram analysis properly with
                    %slips, so we have to break up the trace into fragments
                    FragDwellInd = KV_FragmentTraceAtSlips(DwellInd);
                    % FragDwellInd contains the following fields: (f stands for "Fragment")
                    % FragDwellInd{f}(d).Start
                    % FragDwellInd{f}(d).Finish
                    % FragDwellInd{f}(d).Mean
    
                    %work on each fragment independently
                    ValidatedFragDwellInd       = KV_ValidateDwells_FragDwellInd(RawT,RawY,FiltT,FiltY,FragDwellInd,ContrastThr,MaxSeparation);
                    FinalDwells{p}{fc}          = KV_FinalDwells(DwellInd,RawT,RawY,FiltT,FiltY,CurrentPhageFileName,CurrentFeedbackCycle,Bandwidth);
                    FinalDwellsValidated{p}{fc} = KV_FinalDwellsValidated(ValidatedFragDwellInd,RawT,RawY,FiltT,FiltY,CurrentPhageFileName,CurrentFeedbackCycle,Bandwidth);
                                                
                    % Plot the results, KV on the left, validated on the right
                    KV_PlotFinalResults(RawT,RawY,FiltT,FiltY,FinalDwells{p}{fc},FinalDwellsValidated{p}{fc},...
                                        CurrentFeedbackCycle, PhageData.file(1:end-4), analysisPath);
                end
            end
        end
    end

    save(SaveFile,'FinalDwells','FinalDwellsValidated');
    disp(['Saved stepping data to ' SaveFile]);
    disp('--------------------------------------------------------');
end %function end