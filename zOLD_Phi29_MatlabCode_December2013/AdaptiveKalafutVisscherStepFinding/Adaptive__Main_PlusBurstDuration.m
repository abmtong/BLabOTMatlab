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

    %% Get Step-Finding Parameters
    Prompt = {'Data Acquisition Bandwidth (Hz)', 'Filter Bandwidth (Hz)', 'Step Penalty Factor (3-5 works best)',...
              'Maximum Separation Between Peak and Dwell Candidate(1-2bp)' , 'Contrast Threshold for Histogram Peak Validation(2-3)',...
              'Maximum Time in a Continuous Analysis Stretch (s)'};
          
    Title         = 'Enter the Following Parameters'; Lines = 1;
    Default       = {'2500','See the code','3','2','1.2','20'};
    Answer        = inputdlg(Prompt, Title, Lines, Default);
    SampFreq      = str2num(Answer{1}); %#ok<*ST2NM> %sampling frequency
    PenaltyFactor = str2num(Answer{3}); %penalty factor, 1 is the default for SIC, but larger penalties dicourage overfitting
    MaxSeparation = str2num(Answer{4}); %the peak shouldn't be any further than that from a candidate dwell location
    ContrastThr   = str2num(Answer{5}); %contrast threshold for ksdensity peak validation
    LongestTime   = str2num(Answer{6}); %longest amount of time in one analysis stretch
    
    BandwidthListFast = [60 80 100 200 250]; %for translocation slower than 10 bp/s
    BandwidthListSlow = [50]; %for translocation faster than 10bp/s

    % Parameters for burst duration detection
    tTestWindow = 10; %nr of points
    tTestFilterFactor = 10; %nr of points
    tBurstDetectLevel = 0.75; %how close to the local minimum in log(tSgn) is the burst measured

        
    [IndexFile IndexFilePath] = uigetfile([ [analysisPath filesep] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
                    IndexFile = [IndexFilePath filesep IndexFile];
                     SaveFile = [IndexFile(1:end-4) '_AdaptiveSicStepFinding_PF_' num2str(PenaltyFactor) 'ExtendedRangeForFiltering.mat']; %where the step-finding results will be saved
    
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
                        if MeanVel>10
                            BandwidthList = BandwidthListFast;
                        else
                            BandwidthList = BandwidthListSlow;
                        end
                        
                        for b = 1:length(BandwidthList) %run a separate cycle for each bandwidth
                            Bandwidth = BandwidthList(b);
                            AvgNum = round(SampFreq/Bandwidth);  %filtering factor for filter-and-decimate
                            [RecordOfValidatedDwells{p}{fc}{s}{b} ProposedDwells{p}{fc}{s}{b} FinalDwells{p}{fc}{s}{b} FinalDwellsValidated{p}{fc}{s}{b}] = ...
                                Adaptive_HelperModule(tempRawT,tempRawY,tempRawF,PenaltyFactor,ContrastThr,MaxSeparation,AvgNum,Bandwidth,CurrentPhageName,CurrentPhageFile,CurrentFeedbackCycle,analysisPath,s); %#ok<*AGROW>
                        end
                                                
                        % Compute the total fraction of time spent in validated dwells.
                        % Consider only the validated dwells preceded and followed by valid bursts
                        FractionValid = []; %the default is zero
                        for b = 1:length(BandwidthList) %run a separate cycle for each bandwidth
                            ValidTime = 0; %total time spent in good validated dwells
                            TotalTime = range(tempRawT); %total time spent in this feedback cycle
                            if length(FinalDwellsValidated{p}{fc}{s}{b}.DwellTime)>2 %need at least three valid dwells for this
                                for d = 2:length(FinalDwellsValidated{p}{fc}{s}{b}.DwellTime)
                                    %if both the preceding and following steps are valid, this is a dwell that counts
                                    if ~isnan(FinalDwellsValidated{p}{fc}{s}{b}.StepSize(d-1)) && ~isnan(FinalDwellsValidated{p}{fc}{s}{b}.StepSize(d))
                                        ValidTime = ValidTime+FinalDwellsValidated{p}{fc}{s}{b}.DwellTime(d);
                                    end
                                end
                            end
                            FractionValid(b) = ValidTime/TotalTime;
                        end
                        BestBandwidth{p}{fc}{s}.Index = find(FractionValid==max(FractionValid),1,'First');
                        BestBandwidth{p}{fc}{s}.Value = BandwidthList(BestBandwidth{p}{fc}{s}.Index);
                        BestBandwidth{p}{fc}{s}.FractionValid = FractionValid(BestBandwidth{p}{fc}{s}.Index);
                        disp(['    Section ' num2str(s) ', Best Bandwidth = ' num2str(BestBandwidth{p}{fc}{s}.Value) ' Hz, with ' num2str(round(100*BestBandwidth{p}{fc}{s}.FractionValid)) '% time spent in valid dwells'])
                    end
                    
                    %Determine Burst Duration
                    for s = 1:length(IndexStart) %run a separate cycle for each analysis section 
                        for b = 1:length(BandwidthList) %run a separate cycle for each bandwidth
                            %1. Compute t-test
                            %2. Identify bursts between valid dwells (only those are meaningful)
                            %3. Find the t-test local minimum corresponding to the burst of interest
                            %4. Determine the baseline for the burst of interest (local maxima before&after the local minimum of interest
                            %5. Determine the width of the local minimum at half max/min using a log scale
                             
                            tCont = Adaptive_FilterAndDecimate(tempRawY,tTestFilterFactor); %contour filtered for t-Test analysis
                            tTime = Adaptive_FilterAndDecimate(tempRawT,tTestFilterFactor); %time filtered for t-Test analysis
                            [~, tSgn, ~] = z_FindBursts_TTestWindow(tCont, tTestWindow);
                            
                            DataSet = FinalDwellsValidated{p}{fc}{s}{b};
                            if length(DataSet.DwellTime)>1 %need at least two valid dwells for this
                                FinalDwellsValidated{p}{fc}{s}{b}.tTestTime   = tTime;
                                FinalDwellsValidated{p}{fc}{s}{b}.tTestCont   = tCont;
                                FinalDwellsValidated{p}{fc}{s}{b}.tTestLogSgn = log(tSgn');
                                FinalDwellsValidated{p}{fc}{s}{b}.BurstStartTime    = NaN*FinalDwellsValidated{p}{fc}{s}{b}.StepSize;%there are no burst durations yet
                                FinalDwellsValidated{p}{fc}{s}{b}.BurstFinishTime   = NaN*FinalDwellsValidated{p}{fc}{s}{b}.StepSize;%there are no burst durations yet
                                FinalDwellsValidated{p}{fc}{s}{b}.BurstLogSgnCutoff = NaN*FinalDwellsValidated{p}{fc}{s}{b}.StepSize;%there are no burst durations yet
                                FinalDwellsValidated{p}{fc}{s}{b}.BurstDuration     = NaN*FinalDwellsValidated{p}{fc}{s}{b}.StepSize;%there are no burst durations yet
                                
                                for d = 1:length(DataSet.DwellTime)-1
                                    if DataSet.Start(d+1)-DataSet.Finish(d) == 1 %i.e. if dwell d and d+1 are consecutive
                                        %here we have a valid burst sandwiched between two valid dwells
                                        MinTime = (DataSet.StartTime(d)+DataSet.FinishTime(d))/2;
                                        MaxTime = (DataSet.StartTime(d+1)+DataSet.FinishTime(d+1))/2;
                                        RegionInd = tTime>=MinTime & tTime<=MaxTime; %region of interest in the tTest data
                                        RegionLogSgn = log(tSgn(RegionInd)); %the values of log(tSgn) in the region of interest
                                        RegionTime   = tTime(RegionInd); %the values of time in the region of interest
                                        MinInd = find(RegionLogSgn==min(RegionLogSgn)); %find the local minimum between (StartTime+FinishTime)/2 for dwells d & d+1
                                        %search to the left and to the right for the intersection
                                        %with tBurstDetectLevel. Consider the max to be at zero,
                                        %since that is usually the case
                                        if length(MinInd)==1 %precisely one local minimum point found
                                            Cutoff = RegionLogSgn(MinInd)*tBurstDetectLevel; %where the burst is detected
                                            %search forward
                                            m = MinInd; ForwStatus = 1; ForwTime = NaN;
                                            while ForwStatus
                                                if m>length(RegionLogSgn)-1
                                                    ForwStatus=0; %which stops the search forward
                                                else
                                                    if RegionLogSgn(m)<Cutoff && RegionLogSgn(m+1)>=Cutoff
                                                        %we found where LogSgn intersects the Cutoff
                                                        %for burst detection in the forward region
                                                        ForwTime = RegionTime(m)+(RegionTime(m+1)-RegionTime(m))*(Cutoff-RegionLogSgn(m))/(RegionLogSgn(m+1)-RegionLogSgn(m));
                                                        ForwStatus = 0; %found what we were looking for
                                                    else
                                                        m=m+1;
                                                    end
                                                end
                                            end
                                            %search backward
                                            m = MinInd; BackStatus = 1; BackTime = NaN;
                                            while BackStatus
                                                if m<2
                                                    BackStatus=0; %which stops the search backward
                                                else
                                                    if RegionLogSgn(m)<Cutoff && RegionLogSgn(m-1)>=Cutoff %we found where LogSgn intersects the Cutoff for burst detection in the backward region
                                                        BackTime = RegionTime(m-1)+(RegionTime(m)-RegionTime(m-1))*(Cutoff-RegionLogSgn(m-1))/(RegionLogSgn(m)-RegionLogSgn(m-1));
                                                        BackStatus = 0; %found what we were looking for
                                                    else
                                                        m=m-1;
                                                    end
                                                end
                                            end
                                            if ~isnan(BackTime) && ~isnan(ForwTime) % succesfully found a burst duration
                                                FinalDwellsValidated{p}{fc}{s}{b}.BurstDuration(d) = ForwTime-BackTime; %burst Duration between these two dwells
                                                FinalDwellsValidated{p}{fc}{s}{b}.BurstStartTime(d) = BackTime;
                                                FinalDwellsValidated{p}{fc}{s}{b}.BurstFinishTime(d) = ForwTime;
                                                FinalDwellsValidated{p}{fc}{s}{b}.BurstLogSgnCutoff(d) = Cutoff;
                                            end
                                        end
                                    end
                                end
                                % Make an image for burst detection diagnostics and save it
                                figure; hold on;
                                plot(tTime,log(tSgn),'b');
                                for BurstInd = 1:length(FinalDwellsValidated{p}{fc}{s}{b}.BurstStartTime)
                                    StartTime  = FinalDwellsValidated{p}{fc}{s}{b}.BurstStartTime(BurstInd);
                                    FinishTime = FinalDwellsValidated{p}{fc}{s}{b}.BurstFinishTime(BurstInd);
                                    Cutoff     = FinalDwellsValidated{p}{fc}{s}{b}.BurstLogSgnCutoff(BurstInd);
                                    if ~isnan(StartTime) && ~isnan(FinishTime) && ~isnan(Cutoff)
                                        plot([StartTime FinishTime],Cutoff*[1 1],'r');
                                    end
                                end
                                xlabel('Time(s)'); ylabel('Log of tTest Significance Value');
                                ImageFolderName=[analysisPath filesep 'AdaptiveStepFinding_BurstDetection_ExtendendRangeForFiltering']; %Save the current figure as an image in a folder for later 
                                if ~isdir(ImageFolderName); mkdir(ImageFolderName); end %create the directory
                                ImageFileName = [ImageFolderName filesep CurrentPhageName '_FC' num2str(CurrentFeedbackCycle) '_Sect' num2str(s) '_Band' num2str(Bandwidth) 'Hz' '.png'];
                                saveas(gcf,ImageFileName); close(gcf);
                            end
                        end
                    end
                end
            end
        end
    end

    save(SaveFile,'FinalDwells','FinalDwellsValidated','BandwidthList','BestBandwidth','RecordOfValidatedDwells', 'ProposedDwells');
    disp(['Saved stepping data to ' SaveFile]);
    disp('--------------------------------------------------------');
end