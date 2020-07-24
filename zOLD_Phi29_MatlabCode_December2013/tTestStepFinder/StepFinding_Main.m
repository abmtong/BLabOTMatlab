function [FinalDwells Data]=StepFinding_Main(RawContour,RawTime)
% This function finds steps given the contour length data "Contour" and the
% time vector data "Time"
%
% [FinalDwells Data]=StepFinding_Main(RawContour,RawTime)
%
% Gheorghe Chistol, 23 Nov 2011

%% Set the Analysis Path
%close all;
global analysisPath;
global FinalDwells Data;
if isempty(analysisPath)
    disp('analysisPath not defined. Use "SetAnalysisPath" to define it');
    return;
end



%     %% Load the Index File
%     IndexFile = uigetfile([ [analysisPath '\'] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
%     IndexFile = [analysisPath '\' IndexFile];
%     if ~exist(IndexFile) %if no files were selected or file doesn't exist
%         disp('No Index File phage files were selected'); return;
%     end
% 
%     SaveFile       = [IndexFile(1:end-4) '_Results.mat'];

%organize the data in a structure
Data.Time       = RawTime; %this will be filtered later
Data.Contour    = RawContour;
Data.RawTime    = RawTime;
Data.RawContour = RawContour;

Nmin      = round(ShortestDwell*Bandwidth); %the minimum number of points in a dwell, this helps get rid of very short dwells identified by the algorythm
AvgNum    = round(SampFreq/Bandwidth);  %averaging number
disp(['... Filter Bandwidth : ' num2str(round(Bandwidth)) ' Hz']);

clear Dwells Progress; %clear some variables to avoid conflict
Progress(1)=1; %this is a measure of the progress which allows us to stop the step finding if several consecutive cycles provide no improvement
               %Progress=1 means there was progressin this round
               %Progress=0 means no new steps were found in the data

LoopStatus='continue';

%run an initial bare T-Test calculation, use this to automatically set the Threshold
%the T-Test is run only on this particular feedback cycle "fc" belonging to this particular phage "p"
Data = StepFinding_BareTTest(Data, AvgNum, tWinStart);
%Set the T-test threshold automagically
tTestThr  = StepFinding_AutoSetTTestThr(Data, Percentile, 'NoPlot');

%now run the first T-Test and transition finding calculation using the automatic threshold
[Transitions, Data] = StepFinding_FullTTest(Data,tWinStart,tTestThr);
Dwells{1}           = StepFinding_ConvertTransToDwells(Transitions); %keep the data about all the rounds of t-test analysis in this cell

r=2; %the number of the iteration round, first round was completed above
                
%Repeat the tTest with increasing sensitivity until Nround is reached, or convergence is achieved
while r<=NRound && strcmp(LoopStatus,'continue') 
    tWinCurrent         = tWinStart+(r-1)*tWinIncr; %increase the t-test window 
    [Transitions, Data] = StepFinding_FullTTest(Data,tWinCurrent,tTestThr); %run the tTest

    if ~isempty(Transitions) %if we have any transitions
        Dwells{r}   = StepFinding_ConvertTransToDwells(Transitions);%convert transition data into a more convenient form
        Dwells{r}   = StepFinding_CleanUpDwells(Data,Dwells{r},Nmin,MinStep);%merge steps that are too short(time) or too small(size)

        %Compare new dwells against old dwells and resolve discrepancies
        Dwells{r}   = StepFinding_CompareNewVersusOldDwells(Data,Dwells{r-1},Dwells{r},BinThr);
        Dwells{r}   = StepFinding_CleanUpDwells(Data,Dwells{r},Nmin,MinStep);
        %determine if any progress has been achieved in this cycle of step finding
        Progress(r) = StepFinding_AssessStepFindingProgress(Dwells{r-1},Dwells{r}); 
%-------------------------------------------------- STOPPED HERE --------%                        
    else
        disp('... Threshold is too low, no progress');
        %no more transitions found
        Dwells{r}=Dwells{r-1};
        Progress(r)=0;
    end

    if Progress(r)==1
        disp(['... Progress has been made in round #' num2str(r)]);
    else
        disp(['... No Progress has been made in round #' num2str(r)]);
    end



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

Dwells{end}=StepFinding_DoubleCheckDwells(Data,Dwells{end}); %remove inconsistencies such as zero-duration dwells
%save this to the final data structure
FinalDwells               = Dwells{end};
FinalDwells.Bandwidth     = Bandwidth; %bandwidth
FinalDwells.tTestThr      = tTestThr; %bandwidth
FinalDwells.BinThr        = BinThr; %binomial threshold

H=StepFinding_PlotStepping(Data,RawContour,RawTime,Dwells{end}); %plot the raw data and the stepping data


%save(SaveFile,'FinalDwells');
%disp(['Saved stepping data to ' SaveFile]);