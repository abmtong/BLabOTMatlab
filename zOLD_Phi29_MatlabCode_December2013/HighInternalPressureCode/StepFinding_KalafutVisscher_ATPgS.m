function StepFinding_KalafutVisscher_ATPgS()
    % This function finds all the steps in a defined region of a trace with
    % ATPgS-induced pauses, then plots the entire trace and overlays the steps
    % on top of raw data. It uses only the KV method (without confirmation, for
    % now) and requires fairly high penalties (5-10).
    %
    % USE:  StepFinding_KalafutVisscher_ATPgS()
    %
    % Gheorghe Chistol, 8 July 2011

    %% Set the Analysis Path and the path for the Kalafut-Visscher method
    addpath([pwd filesep 'KalafutVisscher_StepFinding' filesep], '-end'); %where the KV scripts are located
    global analysisPath;
    if isempty(analysisPath)
        disp('analysisPath not defined. Use "SetAnalysisPath" to define it'); return;
    end
    
   

    %% Get Step-Finding Parameters
    Prompt = {'Data Acquisition Bandwidth (Hz)', 'KV Filter Bandwidth (Hz)', 'Step Penalty Factor (3-5 works best)'};
          
    Title         = 'Enter the Following Parameters'; Lines = 1;
    Default       = {'2500','100','5'};
    Answer        = inputdlg(Prompt, Title, Lines, Default);
    SampFreq      = str2num(Answer{1}); %#ok<*ST2NM> %sampling frequency
    Bandwidth     = str2num(Answer{2}); %desired bandwidth after filtering, has to be an integer
    PenaltyFactor = str2num(Answer{3}); %penalty factor, 1 is the default for SIC, but larger penalties dicourage overfitting
    MinPauseDuration = 1;
    %% Load the Index File
    [IndexFile IndexFilePath] = uigetfile([ [analysisPath filesep] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
    IndexFile                 = [IndexFilePath filesep IndexFile];
    SaveFile                  = [IndexFile(1:end-4) '_ResultsKV_ MinPauseDur_' num2str(MinPauseDuration) '.mat']; %where the step-finding results will be saved
    
    if ~exist(IndexFile,'file') %if no files were selected or file doesn't exist
        disp('No Index File phage files were selected'); return;
    end
    
     FullFinalDwells.DwellLocation=[];
     FullFinalDwells.StartTime=[];
     FullFinalDwells.FinishTime=[];
    
    [SelectedPhages SelectedFeedbackCycles] = LoadPhageList(IndexFile); %loads the index of the sub-traces that are good
    FigureH=NaN;
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
                    disp(['! Feedback Cycle #' num2str(SelectedFeedbackCycles{p}(fc)) ' skipped due to insuficient data']);
                else
                    CurrFC = SelectedFeedbackCycles{p}(fc); %current feedback cycle
                    disp(['+ Analyzing Feedback Cycle ' num2str(CurrFC)]);
                    PhageData.contourFiltered{CurrFC} = FiltY;
                    PhageData.timeFiltered{CurrFC}    = FiltT;
                    
                    %we use the Schwartz Information Criterion to identify
                    %dwell candidates, which will later go through a
                    %validation procedure based on the side-view histogram
                    DwellInd = KV_FindSteps(FiltY,PenaltyFactor);


                    FinalDwells{p}{fc} = KV_FinalDwells(DwellInd,RawT,RawY,FiltT,FiltY,CurrentPhageFileName,CurrFC,Bandwidth);
                                              
                    %KV_ATPgS_PlotSingleFeedbackCycle(RawT,RawY,FiltT,FiltY,FinalDwells{p}{fc},CurrFC,PhageData.file(1:end-4),analysisPath);

                    %Plot the results for the entire trace: plot the raw data in light gray, filtered data in dark gray, steps in blue
                    if isnan(FigureH) %the very first feedback cycle for the current phage trace
                        %create the figure and keep the handle for overlaying other feedback cycles
                        FigureH = KV_ATPgS_PlotEntireTrace(RawT,RawY,FiltT,FiltY,FinalDwells{p}{fc},CurrFC,PhageData.file(1:end-4),analysisPath);
                    else
                        FigureH = KV_ATPgS_PlotEntireTrace(RawT,RawY,FiltT,FiltY,FinalDwells{p}{fc},CurrFC,PhageData.file(1:end-4),analysisPath,FigureH);
                    end
                    
                end
            end
            
             FullFinalDwellLocations=[];
             FullFinalDwellStart=[];
             FullFinalDwellEnd=[];
            for fc = 1:length(FinalDwells{p}) %index fc stands for "FeedbackCycle"
                % Identify pause clusters
                if~isempty(FinalDwells{p}{fc})
                FullFinalDwellLocations=[FullFinalDwellLocations FinalDwells{p}{fc}.DwellLocation];
                FullFinalDwellStart=[FullFinalDwellStart FinalDwells{p}{fc}.StartTime];
                FullFinalDwellEnd=[FullFinalDwellEnd FinalDwells{p}{fc}.FinishTime];
                end
                %plot a yellow rectangle to mark a pause cluster
            end
            
            FullFinalDwells.DwellLocation=FullFinalDwellLocations;
            FullFinalDwells.StartTime=FullFinalDwellStart;
            FullFinalDwells.FinishTime=FullFinalDwellEnd;
            FullFinalDwells.DwellTime=FullFinalDwellEnd-FullFinalDwellStart;
            
            MaxSeparation    = 12; %in basepairs
            %MinPauseDuration = 1; %in seconds
            PauseClusters{p} = KV_ATPgS_IdentifyPauseClusters2(FullFinalDwells,FigureH,MaxSeparation,MinPauseDuration);
            
            %save the figure
            figure(FigureH);
            title(['File: ' PhageData.file(1:end-4) ', SIC Penalty: ' num2str(PenaltyFactor)]);
            FolderName=['ATPgS_PauseClusterFinding_MinPauseDur_' num2str(MinPauseDuration)]
            ImageSaveFolder = [analysisPath filesep FolderName];
            if ~exist(ImageSaveFolder,'dir')
                mkdir(ImageSaveFolder);
            end
            saveas(FigureH, [ImageSaveFolder filesep PhageData.file(1:end-4) '_ATPgS_ClusterSearch'],'png');
            saveas(FigureH, [ImageSaveFolder filesep PhageData.file(1:end-4) '_ATPgS_ClusterSearch'],'fig');
            close(FigureH); FigureH = NaN;
        end
    end

    save(SaveFile,'FinalDwells','PauseClusters');
    disp(['Saved stepping data to ' SaveFile]);
    disp('--------------------------------------------------------');
end %function end