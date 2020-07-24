function StepFinding_ProcessTrace()
% This script finds the steps and dwells in the High Internal Pressure data
% It uses a compares old dwells (shorter t-test window) and the
% new dwells (longer t-test window). Sometimes shorter t-test windows
% actually detect steps that longer windows miss. The goal is to retain the
% good dwells identified by the previous rounds of t-test analysis. This
% script incorprates the new, much faster, and hopefully bug free code.
%
% You will need:
% 1) Processed Phage files (mat files)
% 2) An index file with instructions. Here's a sample index file: DataFileName & SelectedFeedbackCycle#
% 070108N90 4 5 6 7 8 
% 092008N40 5 6 7 8
%
% Gheorghe Chistol, 25 Oct 2010
%% Set the Analysis Path
%close all;
global analysisPath;
if isempty(analysisPath)
    disp('analysisPath not defined. Use "SetAnalysisPath" to define it');
    return;
else
    disp(['analysisPath has been set to: ' analysisPath]);
end

%% Ask for parameters
% NRound    = 40; %max #of rounds of iterative step finding
% BinThr    = 0.005; %binomial threshold
% tWinIncr  = 1; %increment in Window size for each round of TTest analysis
% tWinStart = 5; %starting size of the window for TTest analysis 
% SampFreq  = 2500; %sampling frequency
% Bandwidth = 100; %desired bandwidth after filtering, has to be an integer
% AvgNum    = round(SampFreq/Bandwidth);  %averaging number
% ShortestDwell = 0.05; %set the shortest dwell to 30-50 msec
% Nmin          = round(ShortestDwell*Bandwidth); %the minimum number of points in a dwell, this helps get rid of very short dwells identified by the algorythm
% MinStep       = 2; %the smallest step is 2bp, to avoid fractured dwells due to flukes
% Percentile    = 0.10; % Percentile: t-Test threshold percentile. The threshold will be
%                       % set to have 10% of all the Sgn values below the t-Test threshold.
% 
Prompt = {'Maximum Allowed Number of Step-Finding Rounds',...
          'Data Acquisition Bandwidth (Hz)',...
          'Starting T-Test Window Size (pts)',...
          'T-Test Window Size Increment (pts)',...
          'Shortest Dwell Duration (sec)',...
          'Minimum Step Size (bp)',...
          'Automatic T-Test Threshold Percentile',...
          'Binomial Test Threshold (1-confidence)',...
          'Data Filtering Bandwidth (Hz)'
          };

Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'20','2500','5','1','0.05','3','0.01','0.005','200'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);

%Bandwidth     = str2num(Answer{1}); %desired bandwidth after filtering, has to be an integer
NRound        = str2num(Answer{1}); %max #of rounds of iterative step finding
SampFreq      = str2num(Answer{2}); %sampling frequency
tWinStart     = str2num(Answer{3}); %starting size of the window for TTest analysis 
tWinIncr      = str2num(Answer{4}); %increment in Window size for each round of TTest analysis
ShortestDwell = str2num(Answer{5}); %set the shortest dwell to 30-50 msec
MinStep       = str2num(Answer{6}); %the smallest step is 2bp, to avoid fractured dwells due to flukes
Percentile    = str2num(Answer{7}); % Percentile: t-Test threshold percentile. The threshold will be set to have 10% of all the Sgn values below the t-Test threshold.
BinThr        = str2num(Answer{8}); %binomial threshold
Bandwidth     = str2num(Answer{9}); %desired bandwidth after filtering, has to be an integer

%% Load the Index File
IndexFile = uigetfile([ [analysisPath '\'] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
IndexFile = [analysisPath '\' IndexFile];
if ~exist(IndexFile) %if no files were selected or file doesn't exist
    disp('No Index File phage files were selected'); return;
end

SaveFile       = [IndexFile(1:end-4) '_Results.mat'];
[SelectedPhages SelectedFeedbackCycles] = LoadPhageList(IndexFile); %loads the index of the sub-traces that are good

for p=1:length(SelectedPhages)
    %index p stands for "phage" 
    CurrentPhageFileName = [analysisPath '\' 'phage' SelectedPhages{p} '.mat'];
    if ~exist(CurrentPhageFileName,'file') %if the phage data file does not exist
        disp(['!!! Phage Data File does not exist: ' CurrentPhageFileName]);
    else %proceed to analyzing the data
        disp(['+ Analyzing Phage : ' CurrentPhageFileName]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Load the Current Phage Data file
        %CurrentPhageFileName = 'D:\Phi29\2010_ANALYSIS\091310_21kb_250uM_ATP\phage091310N12.mat';
        %clear stepdata;
        load(CurrentPhageFileName);
        PhageData=stepdata; %indexed data fromt the current trace
        %% Run the Step Finding Routine for each Feedback Cycle of the phage trace
        
        for fc=1:length(SelectedFeedbackCycles{p}) %index fc stands for "FeedbackCycle"
            % Find the optimal filtering parameter
            y = PhageData.contour{SelectedFeedbackCycles{p}(fc)};
            t = PhageData.time{SelectedFeedbackCycles{p}(fc)};
                if abs(t(end)-t(1))>1
                AverageVelocity = abs((y(1)-y(end))/(t(1)-t(end)));
                %Bandwidth = 25+1.8*AverageVelocity;
                %Bandwidth = 100;
                Nmin      = round(ShortestDwell*Bandwidth); %the minimum number of points in a dwell, this helps get rid of very short dwells identified by the algorythm
                AvgNum    = round(SampFreq/Bandwidth);  %averaging number

                %25*AverageVelocity; %optimal value we determined empyrically
                AvgNum    = round(SampFreq/Bandwidth);  %averaging number
                disp(['... Filter Bandwidth : ' num2str(round(Bandwidth)) ' Hz']);

                CurrentFeedbackCycle = SelectedFeedbackCycles{p}(fc);
                clear Dwells Progress; %clear some variables to avoid conflict
                Progress(1)=1; %this is a measure of the progress which allows us to stop the step finding if several consecutive cycles provide no improvement
                               %Progress=1 means there was progressin this round
                               %Progress=0 means no new steps were found in the data

                LoopStatus='continue';

                %run an initial bare T-Test calculation, use this to automatically set the Threshold
                %the T-Test is run only on this particular feedback cycle "fc" belonging to this particular phage "p"

                PhageData = BareTTest(PhageData, AvgNum, tWinStart, CurrentFeedbackCycle);
                %Set the T-test threshold automagically
                tTestThr  = AutoSetTTestThr(PhageData, Percentile, CurrentFeedbackCycle, 'NoPlot');

                %now run the first T-Test and transition finding calculation using the automatic threshold
                [Transitions, PhageData] = PhageTTest(PhageData, tWinStart, tTestThr, CurrentFeedbackCycle);
                Dwells{1} = ConvertTransToDwells(Transitions); %keep the data about all the rounds of t-test analysis in this cell

                r=2; %the number of the iteration round, first round was completed above
                %Repeat the tTest with increasing sensitivity until Nround is reached, or convergence is achieved
                while r<=NRound && strcmp(LoopStatus,'continue') 
                    tWinCurrent = tWinStart+(r-1)*tWinIncr; %increase the t-test window 
                    [Transitions, PhageData] = PhageTTest(PhageData, tWinCurrent, tTestThr, CurrentFeedbackCycle); %run the tTest

                    %convert transition data into a more convenient form
                    Dwells{r}   = ConvertTransToDwells(Transitions);

                    %merge steps that are too short(time) or too small(size)
                    Dwells{r}   = CleanUpDwells(PhageData, Dwells{r}, Nmin, MinStep, CurrentFeedbackCycle);  %#ok<*SAGROW>

                    %Compare new dwells against old dwells and resolve discrepancies
                    Dwells{r}   = CompareNewVersusOldDwells(PhageData, Dwells{r-1}, Dwells{r}, BinThr, CurrentFeedbackCycle);
                    Dwells{r}   = CleanUpDwells(PhageData, Dwells{r}, Nmin, MinStep, CurrentFeedbackCycle);

                    %determine if any progress has been achieved in this cycle of step finding
                    Progress(r) = AssessStepFindingProgress(Dwells{r-1},Dwells{r}); 

                    if Progress(r)==1
                        disp(['... Progress has been made in round #' num2str(r)]);
                    else
                        disp(['... No Progress has been made in round #' num2str(r)]);
                    end

                    LimX = [min(PhageData.timeFiltered{CurrentFeedbackCycle})     max(PhageData.timeFiltered{CurrentFeedbackCycle})];
                    LimY = [min(PhageData.contourFiltered{CurrentFeedbackCycle})  max(PhageData.contourFiltered{CurrentFeedbackCycle})];

                    %Progress is 0 if nothing changed, or 1 if the detected steps changed
                    N=3;
                    if length(Progress)>N
                        if sum(Progress(end-N+1:end))==0
                            LoopStatus='stop'; %this tells the main loop when to stop trying to find more steps
                            disp(['... Convergence has been achieved after ' num2str(r) ' rounds of analysis']);
                        else
                            r=r+1;
                        end
                    else
                        r=r+1;
                    end
                end

                %Check the Dwell durations, if there are dwells with zero
                %duration, remove them, update the StepSize and other values accordingly
                RemoveIndex = find(Dwells{end}.Npts==1); %index of the dwells that need to be removed
                for ri=1:length(RemoveIndex)
                    s=RemoveIndex(ri);
                    if s>1
                       Dwells{end}.end(s-1)=Dwells{end}.start(s); %the current dwell, "s" will be removed, adjust the previous dwell accordingly
                    else
                        Dwells{end}.start(s+1)=Dwells{end}.start(s); %in case the very first dwell has a zero duration
                    end
                end
                
                Dwells{end}.start(RemoveIndex)=[]; %remove the data corresponding to those zero-duration dwells
                Dwells{end}.end(RemoveIndex)=[]; %remove the data corresponding to those zero-duration dwells
                disp(['...' num2str(length(RemoveIndex)) ' zero-duration Dwells removed']);
                %----- Recalculate the remaining parameters based on start & end values
                Dwells{end}.Npts=[]; %#ok<*AGROW>
                Dwells{end}.mean=[];
                Dwells{end}.std=[];
                Dwells{end}.StepSize=[];
                Dwells{end}.StepLocation=[];
                Dwells{end}.DwellTime=[];
                Dwells{end}.DwellLocation=[];
                
                for s=1:length(Dwells{end}.start)
                    ContData = PhageData.contourFiltered{CurrentFeedbackCycle}(Dwells{end}.start(s):Dwells{end}.end(s)); %contour data
                    TimeData = PhageData.timeFiltered{CurrentFeedbackCycle}(Dwells{end}.start(s):Dwells{end}.end(s)); %time data
                    Dwells{end}.Npts(s)          = length(ContData);
                    Dwells{end}.mean(s)          = mean(ContData);
                    Dwells{end}.std(s)           = std(ContData);
                    Dwells{end}.DwellTime(s)     = TimeData(end)-TimeData(1);
                    Dwells{end}.DwellLocation(s) = mean(ContData); %same thing as mean                    
                end
                
                for s=1:length(Dwells{end}.mean)-1 %we can't calculate the step-size after the last dwell
                    Dwells{end}.StepSize(s)     = Dwells{end}.mean(s+1)-Dwells{end}.mean(s);
                    Dwells{end}.StepLocation(s) = (Dwells{end}.mean(s+1)+Dwells{end}.mean(s))/2; %where along DNA did this step occur?
                end
                
                 %------------------------- PLOTTING------------------------
                 H=figure;
                 set(gca,'Color',[1 1 1]);
                 %Plot the Filtered Data
                 plot(PhageData.timeFiltered{CurrentFeedbackCycle}, PhageData.contourFiltered{CurrentFeedbackCycle},'Color',[0.5 0.5 0.5]);
                 grid off;
                 %Plot the Stepping
                 PlotDwells(Dwells{end},PhageData,'b',CurrentFeedbackCycle);
                 title([PhageData.file '; Feedback Cycle #' num2str(CurrentFeedbackCycle) '; Round ' num2str(r) ...
                        ' AvgVel:' num2str(round(AverageVelocity)) 'bp/sec' ...
                        ' Bandwidth:' num2str(round(Bandwidth)) 'Hz']);
                 set(gcf, 'Position',[5 5 1350 680]); %full screen figure
                 set(gca,'XLim',LimX,'YLim',LimY);
                 %Save the current figure as an image in a folder for later 
                 ImageFolderName=[analysisPath '\' 'StepFindingResults_Images'];
                 
                 if ~isdir(ImageFolderName);
                     mkdir(ImageFolderName);%create the directory
                 end
                 ImageFileName = [ImageFolderName '\' PhageData.file(1:end-4) '_' num2str(CurrentFeedbackCycle) '.png'];
                 saveas(H,ImageFileName);
                 close(H);
                %------------------------- PLOTTING------------------------
                
                %save this to the final data structure
                FinalDwells{p}{fc}               = Dwells{end};
                FinalDwells{p}{fc}.PhageFile     = CurrentPhageFileName; %file name
                FinalDwells{p}{fc}.FeedbackCycle = CurrentFeedbackCycle; %trace ID
                FinalDwells{p}{fc}.Band          = Bandwidth; %bandwidth
                FinalDwells{p}{fc}.tTestThr      = tTestThr; %bandwidth
                FinalDwells{p}{fc}.BinThr        = BinThr; %binomial threshold
                disp('--------------------------------------------------------');
            else
                disp(['! Feedback Cycle #' num2str(SelectedFeedbackCycles{p}(fc)) 'because it contains insuficient data']);
            end
        end
    end
end

save(SaveFile,'FinalDwells');
disp(['Saved stepping data to ' SaveFile]);
return;