function Adaptive__Main()
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
    
    global analysisPath;

%% Ask for parameters
Prompt = {'Maximum Allowed Number of Step-Finding Rounds',...
          'Data Acquisition Bandwidth (Hz)',...
          'Starting T-Test Window Size (pts)',...
          'T-Test Window Size Increment (pts)',...
          'Shortest Dwell Duration (sec)',...
          'Minimum Step Size (your units)',...
          'Automatic T-Test Threshold Percentile',...
          'Binomial Test Threshold (1-confidence)',...
          'Data Filtering Bandwidth (Hz)'
          };

Title = 'Enter the Following Parameters'; Lines = 1;
Default = {'20','2000','5','1','0.01','5','0.01','0.005','100'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
NRound        = str2num(Answer{1}); %max #of rounds of iterative step finding
SampFreq      = str2num(Answer{2}); %sampling frequency
tWinStart     = str2num(Answer{3}); %starting size of the window for TTest analysis 
tWinIncr      = str2num(Answer{4}); %increment in Window size for each round of TTest analysis
ShortestDwell = str2num(Answer{5}); %set the shortest dwell to 30-50 msec
MinStep       = str2num(Answer{6}); %the smallest step is 2bp, to avoid fractured dwells due to flukes
Percentile    = str2num(Answer{7}); % Percentile: t-Test threshold percentile. The threshold will be set to have 10% of all the Sgn values below the t-Test threshold.
BinThr        = str2num(Answer{8}); %binomial threshold
Bandwidth     = str2num(Answer{9}); %desired bandwidth after filtering, has to be an integer

    %% Get Step-Finding Parameters
   % Prompt = {'Data Acquisition Bandwidth (Hz)', 'Filter Bandwidth (Hz)', 'Step Penalty Factor (3-5 works best)',...
             % 'Maximum Separation Between Peak and Dwell Candidate(1-2bp)' , 'Contrast Threshold for Histogram Peak Validation(2-3)',...
             % 'Maximum Time in a Continuous Analysis Stretch (s)'};
          
    %Title         = 'Enter the Following Parameters'; Lines = 1;
    %Default       = {'2500','See the code','1','2','1.2','10'};
    %Answer        = inputdlg(Prompt, Title, Lines, Default);
    %SampFreq      = str2num(Answer{1}); %#ok<*ST2NM> %sampling frequency
    %PenaltyFactor = str2num(Answer{3}); %penalty factor, 1 is the default for SIC, but larger penalties dicourage overfitting
    %MaxSeparation = str2num(Answer{4}); %the peak shouldn't be any further than that from a candidate dwell location
    %ContrastThr   = str2num(Answer{5}); %contrast threshold for ksdensity peak validation
    %LongestTime   = str2num(Answer{6}); %longest amount of time in one analysis stretch
    
    %BandwidthListFast = [250]; %for translocation faster than 10 bp/s    
    %BandwidthListFast = [70 80 90]; %for translocation faster than 10 bp/s    
    %BandwidthListFast = [90 100 110 120 130]; %for translocation faster than 10 bp/s
    %BandwidthListSlow = [100]; %for translocation slowe than 10bp/s
    
    [IndexFile IndexFilePath] = uigetfile([ [analysisPath filesep] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
                    IndexFile = [IndexFilePath filesep IndexFile];
                     SaveFile = [IndexFile(1:end-4) '_tTestStepFinfing.mat']; %where the step-finding results will be saved
    
    if ~exist(IndexFile,'file') %if no files were selected or file doesn't exist
        disp('No Index File phage files were selected'); return;
    end
    
    [SelectedPhages SelectedFeedbackCycles] = Adaptive_LoadPhageList(IndexFile); %loads the index of the sub-traces that are good

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
                
                if range(RawT)<0.25 %the trace needs to have more than 0.25 sec worth of data 
                    disp(['! Feedback Cycle #' num2str(SelectedFeedbackCycles{p}(fc)) 'skipped due to insuficient data']);
                else
                    disp(['+ Analyzing Feedback Cycle ' num2str(CurrentFeedbackCycle)]);
                    if range(RawT)>LongestTime %this can take too long to analyze, break it up
                        NumSections = ceil(range(RawT/LongestTime)); %number of analysis sections that are needed
                        IndexStart  = 1:round(length(RawT)/NumSections):length(RawT); %where a section starts
                        IndexStart  = IndexStart(1:NumSections); %to avoid sections with no data
                        IndexFinish = [IndexStart(2:end)-1 length(RawT)]; %where a section ends, in terms of index
                    else %no need to break up into pieces
                        IndexStart  = 1;
                        IndexFinish = length(RawT);
                    end
                    
                    for s = 1:length(IndexStart) %run a separate cycle for each analysis section                        
                        tempRawT = RawT(IndexStart(s):IndexFinish(s));
                        tempRawY = RawY(IndexStart(s):IndexFinish(s));
                        tempRawF = RawF(IndexStart(s):IndexFinish(s));
                        MeanVel = round(range(tempRawY)/range(tempRawT));
                        [FinalDwells{p}{fc}{s} RawData{p}{fc}{s}]=StepFinding_Main(tempRawY,tempRawT);
                    end
                end
            end
        end
    end

    save(SaveFile,'FinalDwells','RawData');
    disp(['Saved stepping data to ' SaveFile]);
    disp('--------------------------------------------------------');
end