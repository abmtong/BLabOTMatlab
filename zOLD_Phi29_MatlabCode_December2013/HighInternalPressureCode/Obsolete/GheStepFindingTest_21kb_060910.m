% This script finds the steps and dwells in the High Internal Pressure data
% It uses a method of comparing old dwells (shorter t-test window) and the
% new dwells (longer t-test window). Sometimes shorter t-test windows
% actually detect steps that longer windows miss. The goal is to retain the
% good dwells identified by the previous rounds of t-test analysis. This
% script incorprates the new, improved, and hopefully error free algorythm
% of comparing with the old dwells.
% 
% Revised 15 June 2010 (speeded up quite a bit, simplified)
%
% Gheorghe Chistol, June 9st, 2010

close all;
%% Add the Path where most files are stored
path('D:\Phi29\MatlabCode\MatlabFilesGhe\MatlabGeneral\NewAnalysisCode\',path);
%the step finding scripts and functions are stored in a separate folder

%% Load Phages, calculate velocities, and index appropriately
%SetAnalysisPath;
Phages=LoadPhage();
clear stepdata;
PhageData = PhageVelocity(Phages);
IndexFile = 'D:\Phi29\MatlabCode\MatlabFilesGhe\MatlabGeneral\GheStepFindingCode\SampleDataHIP\PhageIndex.txt'; %sample trace
SaveFile = [IndexFile(1:end-4) '_save.mat'];
[PhageDataInd ]= GheLoadPhageList(PhageData, IndexFile); %loads the index of the sub-traces that are good

%% Set Parameters

%%
for n=1:length(PhageDataInd) %here n is the phage number
    clear Dwells Progress; %clear some variables to avoid conflict
    NRound    = 20; %#of rounds of iterative step finding
    BinThr    = 0.005; %binomial threshold
    tWinIncr  = 1; %increment in Window size for each round of TTest analysis
    tWinStart = 5; %starting size of the window for TTest analysis 
    SampFreq  = 2500;     %sampling frequency
    Bandwidth = PhageDataInd(n).Band; %desired bandwidth after filtering, has to be an integer
    %tTestThr  = PhageDataInd(n).Thr;  %t-test Threshold
    AvgNum    = SampFreq/Bandwidth;  %averaging number
    ShortestDwell = 0.05; %set the shortest dwell to 30-50 msec
    Nmin          = round(ShortestDwell*Bandwidth); %the minimum number of points in a dwell, this helps get rid of very short dwells identified by the algorythm
    MinStep       = 2; %the smallest step is 2bp, to avoid fractured dwells due to flukes
    Percentile    = 0.10; % Percentile: t-Test threshold percentile. The threshold will be
                          % set to have 10% of all the Sgn values below the t-Test threshold.

    %run an initial bare T-Test calculation, use this to automatically set the Threshold
    PhageData = GheBareTTest(Phages, AvgNum, tWinStart, PhageDataInd(n));
    tTestThr  = GheAutoSetTTestThr(PhageData,Percentile,'NoPlot');
    
    %now run the T-Test and transition finding calculation using the automatic threshold
    [Transitions, PhageData] = GhePhageTTest(Phages, [AvgNum tWinStart tTestThr], PhageDataInd(n), 'nothing'); %run this round of TTest
    
    Dwells{1} = GheConvertTransToDwells(Transitions); %keep the data about all the rounds of t-test analysis in this cell
    Progress(1)=1; %this is a measure of the progress which allows us to stop the step finding if several consecutive cycles provide no improvement
    r=2; %the number of the iteration round, the first round was already completed above
    LoopStatus='continue';

    while r<=NRound && strcmp(LoopStatus,'continue') %continue until Nround is reached, or convergence is achieved
        tWinCurrent = tWinStart+(r-1)*tWinIncr; %increase the t-test window 
        [Transitions, PhageData] = GhePhageTTest(Phages, [AvgNum tWinCurrent tTestThr], PhageDataInd(n), 'nothing'); %run this round of TTest
        Dwells{r}   = GheConvertTransToDwells(Transitions);
        Dwells{r}   = GheCleanUpDwells(PhageData, Dwells{r}, Nmin, MinStep);
        Dwells{r}   = GheCompareNewVersusOldDwells(PhageData, Dwells{r-1}, Dwells{r}, BinThr, Nmin);
        Dwells{r}   = GheCleanUpDwells(PhageData, Dwells{r}, Nmin, MinStep);
        Progress(r) = GheAssessProgress(Dwells{r-1},Dwells{r}); %determine if any progress has been achieved in this cycle of step finding
        
        if Progress(r)==1
            disp(['Progress has been made in round #' num2str(r)]);
        else
            disp(['No Progress has been made in round #' num2str(r)]);
        end
         
%         figure; hold on;
%         set(gca,'Color',[0 0 0]);
%         plot(PhageData.time, PhageData.contour,'Color',[0.5 0.5 0.5]);
%         grid off;
%         GhePlotDwells(Dwells{r},PhageData,'g');
%         title([PhageDataInd(n).file '; subtrace #' num2str(PhageDataInd(n).stID) '; round #' num2str(r)]);
%         set(gcf, 'Position',[5 5 1350 680]); %full screen figure

        %Progress is 0 if nothing changed, or 1 if the detected steps changed
        N=3;
        if length(Progress)>N
            if sum(Progress(end-N+1:end))==0
                LoopStatus='stop'; %this tells the main loop when to stop trying to find more steps
                disp(['Convergence has been achieved after ' num2str(r) ' rounds of analysis']);
            else
                r=r+1;
            end
        else
            r=r+1;
        end
    end

    if r>NRound
        r=NRound; %in case we ran over
    end
    
    figure; hold on;
    set(gca,'Color',[1 1 1]);
    plot(PhageData.time, PhageData.contour,'Color',[0.5 0.5 0.5]);
    grid off;
    GhePlotDwells(Dwells{r},PhageData,'k');
    title([PhageDataInd(n).file '; subtrace #' num2str(PhageDataInd(n).stID) '; round #' num2str(r)]);
    set(gcf, 'Position',[5 5 1350 680]); %full screen figure
    
    %Update the stepsize values
    Dwells{end}.StepSize=[]; %empty it first
    for s=1:length(Dwells{end}.mean)-1
        Dwells{end}.StepSize(s) = Dwells{end}.mean(s+1)-Dwells{end}.mean(s);
        Dwells{end}.StepLocation(s) = (Dwells{end}.mean(s+1)+Dwells{end}.mean(s))/2; %where along the DNA the steps occur
    end
    %Update the Dwell Time values
    for d=1:length(Dwells{end}.mean)
        Dwells{end}.DwellTime(d)=(Dwells{end}.Npts(d)-1)/Bandwidth; %the dwell times in seconds
    end
    
    %save this to the final data structure
    %FinalDwells{n}          = Dwells{end};
    %FinalDwells{n}.File     = PhageDataInd(n).file; %file name
    %FinalDwells{n}.TraceID  = PhageDataInd(n).stID; %trace ID
    %FinalDwells{n}.Band     = PhageDataInd(n).Band; %bandwidth
    %FinalDwells{n}.tTestThr = PhageDataInd(n).Thr; %bandwidth
    %FinalDwells{n}.BinThr   = BinThr; %binomial threshold
end
%save(SaveFile,'FinalDwells');
%disp(['Saved the dwell data to ' SaveFile]);