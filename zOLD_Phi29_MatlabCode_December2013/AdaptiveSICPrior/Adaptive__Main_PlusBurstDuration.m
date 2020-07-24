function Adaptive__Main_PlusBurstDuration()
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
    Default       = {'2500','See the code','1','2','1.2','10'};
    Answer        = inputdlg(Prompt, Title, Lines, Default);
    SampFreq      = str2num(Answer{1}); %#ok<*ST2NM> %sampling frequency
    PenaltyFactor = str2num(Answer{3}); %penalty factor, 1 is the default for SIC, but larger penalties dicourage overfitting
    MaxSeparation = str2num(Answer{4}); %the peak shouldn't be any further than that from a candidate dwell location
    ContrastThr   = str2num(Answer{5}); %contrast threshold for ksdensity peak validation
    LongestTime   = str2num(Answer{6}); %longest amount of time in one analysis stretch
    
    BandwidthListFast = [75]; %for translocation slower than 10 bp/s
    BandwidthListSlow = [75]; %for translocation faster than 10bp/s

    % Parameters for burst duration detection
    tTestWindow = 10; %nr of points
    tTestFilterFactor = 20; %nr of points
    tBurstDetectLevel = 0.75; %how close to the local minimum in log(tSgn) is the burst measured

    
    [IndexFile IndexFilePath] = uigetfile([ [analysisPath filesep] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
                    IndexFile = [IndexFilePath filesep IndexFile];
                     SaveFile = [IndexFile(1:end-4) '_AdaptiveSicStepFindingPlusBurst.mat']; %where the step-finding results will be saved
    
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
                            [FinalDwells{p}{fc}{s}{b} FinalDwellsValidated{p}{fc}{s}{b} KernelDensity] = ...
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
                                    if DataSet.Start(d+1)==DataSet.Finish(d)%i.e. if dwell d and d+1 are consecutive
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
                                
                                %% Create a visual diagnostic Plot
                                % Make an image for burst detection diagnostics and save it
                                CurrFig  = figure('Units','normalized','Position',[0.0059 0.0104 0.4883 0.8880],'PaperPosition',[0 0 8 8]); 
                                MainAxes   = axes('Units','normalized','Position',[0.1379 0.3534 0.5797 0.5878],'Box','on','XTickLabel',[]); 
                                TTestAxes  = axes('Units','normalized','Position',[0.1379 0.0674 0.5797 0.2786],'Box','on','YTick',[]); 
                                KernelAxes = axes('Units','normalized','Position',[0.7256 0.3534 0.2624 0.5878],'Box','on','XTick',[],'YTickLabel',[]); 
                                
                                CurrValDwells = FinalDwellsValidated{p}{fc}{s}{b};
                                %>>>>>>> first plot the trace and the validated dwells
                                %plot vertical dashed lines at every valid step location
                                %plot horizontal dashed lines at every valid dwell location
                                axes(MainAxes); hold on;
                                plot(RawT, RawY, 'Color', 0.8*[1 1 1]);
                                FiltT = Adaptive_FilterAndDecimate(RawT,AvgNum);
                                FiltY = Adaptive_FilterAndDecimate(RawY,AvgNum);
                                plot(FiltT, FiltY, 'Color', 0.5*[1 1 1],'LineWidth',1);
                                set(gca,'XLim',[min(RawT) max(RawT)]);
                                set(gca,'YLim',[min(RawY) max(RawY)]);
                                ylabel('DNA Tether Length (bp)');
                                
                                % ############## Plot the Validated Steps
                                x=[]; y=[]; DwellLocation =[];
                                for d=1:length(CurrValDwells.DwellLocation)
                                    DwellLocation(d) =  CurrValDwells.DwellLocation(d);    
                                    tempx = [CurrValDwells.StartTime(d) CurrValDwells.FinishTime(d)];  %beginning/end of the current dwell
                                    tempy =  CurrValDwells.DwellLocation(d)*[1 1];

                                    if d==1 %very first validated dwell for this feedback cycle
                                        x = tempx; y = tempy; %start new dwell cluster from scratch 
                                    else
                                        %no longer the very first validated dwell 
                                        if CurrValDwells.Start(d) == CurrValDwells.Finish(d-1)
                                            %we have temporally consecutive dwells, the same dwell cluster continue constructing the current cluster            
                                            x(end+1:end+2)   = tempx; y(end+1:end+2)   = tempy;
                                        else
                                            plot(x,y,'-k','LineWidth',1); %the previous cluster has ended, plot it
                                            x = tempx; y = tempy;%start new dwell cluster from scratch 
                                        end
                                    end
                                    plot(tempx,tempy,'k','LineWidth',3); %plot the level of the dwell so we can see it better
                                end
                                plot(x,y,'-k','LineWidth',1); %the very last cluster has ended, plot it
                                % plot horizontal dashed lines that should coincide with valid Kernel Density peaks
                                XLim = get(gca,'XLim');
                                for d=1:length(DwellLocation)
                                    plot([CurrValDwells.FinishTime(d) XLim(2)],DwellLocation(d)*[1 1],':k','LineWidth',0.5);
                                end
                                % plot vertical dashed lines that should coincide with minima in the log(tTestSignificance)
                                YLim = get(gca,'YLim');
                                for d=1:length(CurrValDwells.FinishTime)-1
                                    if CurrValDwells.FinishTime(d)==CurrValDwells.StartTime(d+1) %there are two consecutive valid dwells, and therefore a valid burst in between 
                                        plot(CurrValDwells.FinishTime(d)*[1 1],[YLim(1) CurrValDwells.DwellLocation(d)],':k','LineWidth',0.5);
                                    end
                                end
                                %plot rectangular patches to denote the burst duration
                                for b = 1:length(CurrValDwells.BurstDuration)
                                    if ~isnan(CurrValDwells.BurstDuration(b)) %there is a burst associated with every valid dwell, but some of them are NaN
                                        x = [CurrValDwells.BurstStartTime(b)*[1 1] CurrValDwells.BurstFinishTime(b)*[1 1]];
                                        y = [YLim(1) CurrValDwells.DwellLocation(b)*[1 1] YLim(1)];
                                        P=patch(x,y,'g'); set(P,'FaceAlpha',0.5,'LineStyle','none');
                                    end
                                end
                                title([CurrentPhageName  ', FC#' num2str(CurrValDwells.FeedbackCycle) ', Sect' num2str(s) ', Vel=' num2str(round(range(FiltY)/range(FiltT))) 'bp/s, f=' num2str(CurrValDwells.Bandwidth) 'Hz']);
                                
                                %>>>>>>> then plot the kernel density with the validated dwells on the side
                                axes(KernelAxes); hold on;
                                for f = 1:length(KernelDensity) %there might be several fragments, due to slips
                                    plot(-KernelDensity{f}.KernelValue,KernelDensity{f}.KernelGrid,'b','LineWidth',1.5);
                                    PeakInd = KernelDensity{f}.LocalMaxima.LocalMaxInd(logical(KernelDensity{f}.LocalMaxima.IsValid)); %1 and 0 in logical/binary i.e. T/F
                                    plot(-KernelDensity{f}.KernelValue(PeakInd),KernelDensity{f}.KernelGrid(PeakInd),'.r','MarkerSize',15);
                                end
                                xlabel('Kernel Density');
                                set(gca,'YLim',[min(RawY) max(RawY)]); %axes are inverted here
                                set(gca,'XLim',[-1.1 0]); %axes are inverted here
                                set(gca,'XTick',[]);
                                XLim = get(gca,'XLim');
                                for d=1:length(DwellLocation)
                                    plot(XLim,DwellLocation(d)*[1 1],':k','LineWidth',0.5);
                                end
                                
                                %>>>>>>> then plot the t-test significance levels and emphasize dwell duration
                                axes(TTestAxes); hold on;
                                plot(tTime,log(tSgn),'b','LineWidth',1.5);
                                for BurstInd = 1:length(CurrValDwells.BurstStartTime)
                                    StartTime  = CurrValDwells.BurstStartTime(BurstInd);
                                    FinishTime = CurrValDwells.BurstFinishTime(BurstInd);
                                    Cutoff     = CurrValDwells.BurstLogSgnCutoff(BurstInd);
                                    if ~isnan(StartTime) && ~isnan(FinishTime) && ~isnan(Cutoff)
                                        plot([StartTime FinishTime],Cutoff*[1 1],'r','LineWidth',2);
                                    end
                                end
                                set(gca,'YLim',[min(log(tSgn))*1.05 0]);
                                set(gca,'XLim',[min(RawT) max(RawT)]);
                                xlabel('Time(s)'); ylabel('Log of tTest Significance Value');
                                % plot vertical dashed lines that should coincide with minima in the log(tTestSignificance)
                                YLim = get(gca,'YLim');
                                for d=1:length(CurrValDwells.FinishTime)-1
                                    if CurrValDwells.FinishTime(d)==CurrValDwells.StartTime(d+1) %there are two consecutive valid dwells, and therefore a valid burst in between 
                                        plot(CurrValDwells.FinishTime(d)*[1 1],YLim,':k','LineWidth',0.5);
                                    end
                                end
                                %plot rectangular patches to denote the burst duration
                                for b = 1:length(CurrValDwells.BurstDuration)
                                    if ~isnan(CurrValDwells.BurstDuration(b)) %there is a burst associated with every valid dwell, but some of them are NaN
                                        x = [CurrValDwells.BurstStartTime(b)*[1 1] CurrValDwells.BurstFinishTime(b)*[1 1]];
                                        y = [YLim(1) YLim(2)*[1 1] YLim(1)];
                                        P=patch(x,y,'g'); set(P,'FaceAlpha',0.5,'LineStyle','none');
                                    end
                                end
                                
% >> CurrValDwells = 
%                 Start: [1 5 15 28 44 69 84 97 115 128 143 157]
%                Finish: [5 15 28 44 69 84 97 115 128 143 157 171]
%             StartTime: [1x12 double]
%            FinishTime: [1x12 double]
%             DwellTime: [1x12 double]
%         DwellLocation: [1x12 double]
%            DwellForce: [1x12 double]
%              StepSize: [1x12 double]
%          StepLocation: [1x12 double]
%             StepForce: [1x12 double]
%             PhageFile: 'D:\250uMatp Ghe\phage080911N75.mat'
%         FeedbackCycle: 16
%             Bandwidth: 200
%              FiltTime: [1x176 double]
%              FiltCont: [1x176 single]
%             FiltForce: [1x176 single]
%             tTestTime: [1x229 double]
%             tTestCont: [1x229 single]
%           tTestLogSgn: [1x229 single]
%        BurstStartTime: [1x12 double]
%       BurstFinishTime: [1x12 double]
%     BurstLogSgnCutoff: [1x12 double]
%         BurstDuration: [1x12 double]
                                
                                %>>>>>>>> Save Image
                                ImageFolderName=[analysisPath filesep 'AdaptiveStepFinding_BurstDetection']; %Save the current figure as an image in a folder for later 
                                if ~isdir(ImageFolderName); mkdir(ImageFolderName); end %create the directory
                                ImageFileName = [ImageFolderName filesep CurrentPhageName '_FC' num2str(CurrentFeedbackCycle) '_Sect' num2str(s) '_Band' num2str(Bandwidth) 'Hz' '.png'];
                                saveas(CurrFig,ImageFileName);
%                                 ImageFileName = [ImageFolderName filesep CurrentPhageName '_FC' num2str(CurrentFeedbackCycle) '_Sect' num2str(s) '_Band' num2str(Bandwidth) 'Hz' '.fig'];
%                                 saveas(CurrFig,ImageFileName); 
                                close(CurrFig);
                            end
                        end
                    end
                end
            end
        end
    end

    save(SaveFile,'FinalDwells','FinalDwellsValidated','BandwidthList','BestBandwidth');
    disp(['Saved stepping data to ' SaveFile]);
    disp('--------------------------------------------------------');
end