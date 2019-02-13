% This script finds the steps and dwells in the High Internal Pressure data
% This script takes off where the 052410 script left and adds a method of
% comparing old dwells (shorter t-test window) and the new dwells (longer
% t-test window). Sometimes shorter t-test windows actually detect steps
% that longer windows miss. The goal is to retain the good dwells
% identified by the previous rounds of t-test analysis.

% Gheorghe Chistol: June 1st, 2010
close all; clear all;
%% Add the Path where most files are stored
path('C:\Documents and Settings\Phi29\Desktop\MatlabCode\MatlabFilesGhe\MatlabGeneral\NewAnalysisCode\',path);
%the step finding scripts and functions are stored in a separate folder

%% Load Phages, calculate velocities, and index appropriately
%load('./SampleDataHIP/phage051510N20.mat'); %for now work with a sample trace
%load('C:/Documents and Settings/Phi29/Desktop/HIP_Analysis/21kb/031610/phage031610N29.mat'); 
%load('C:/Documents and Settings/Phi29/Desktop/HIP_Analysis/21kb/031610/phage031610N27.mat'); 
%load('C:/Documents and Settings/Phi29/Desktop/HIP_Analysis/21kb/031610/phage031610N22.mat'); 
%phages = stepdata;
SetAnalysisPath;
phages=LoadPhage();
clear stepdata;
phageData = PhageVelocity(phages);
%IndexFile = 'C:\Documents and Settings\Phi29\Desktop\HIP_Analysis\21kb\21kb_031110N19.txt'; %do it one phage at a time
IndexFile = 'C:\Documents and Settings\Phi29\Desktop\HIP_Analysis\21kb\TestingIndex.txt'; %do it one phage at a time
%SaveFile = [IndexFile(1:end-4) '.mat'];

[phageDataInd ]= GheLoadPhageList(phageData, IndexFile); %loads the index of the sub-traces that are good

%% Set Parameters
fsamp = 2500;     %sampling frequency
band = 250;       %bandwidth (after downsampling)?
av  = fsamp/band;  %averaging number,
Thr = 1.5e-2;    %tresholod for the T-Test
NRound = 20;
col = 'b';        %plot color
binMult = 1;

%% Initial round of Step Finding
%the steps were found using the Ttest algorythm with a very large window
%size, three times the original window size 3*tWin
%[trans, phageData] = GhePhageTTest(phages, [av tWin thresh], phageDataInd, 'nothing');
%IndexedData=phages(1);
%IndexedData.time = IndexedData.time(phageDataInd(1).stID);
%IndexedData.contour = IndexedData.contour(phageDataInd(1).stID);
%IndexedData.force = IndexedData.force(phageDataInd(1).stID);
%IndexedData.forceX_err = '';
%IndexedData.forceY_err = '';
%IndexedData.trapX = '';
%IndexedData.trapY = '';


%figure; hold on;
%plot(phageData(1).time, phageData(1).contour,'b');
%plot(phageData(1).timeFit, phageData(1).contourFit,'k');



%%
for n=1:length(phageDataInd)
    clear dwells;

    BinThr = 0.005; %binomial threshold, half a percent
    tWinIncrement = 1; %increment in Window size for each round of TTest analysis
    tWin=5;
    
    %band = phageDataInd(n).Band; %desired bandwidth after filtering
    %Thr = phageDataInd(n).Thr;  %t-test Threshold
    %av  = fsamp/band;  %averaging number
    
    [trans, phageData] = GhePhageTTest(phages, [av tWin Thr], phageDataInd(n), 'nothing'); %run this round of TTest

    %keep the data about all the rounds of t-test analysis in this cell
    Dwells{1} = GheConvertTransToDwells(trans);

    clear Progress;
    Progress(1)=1; %this is a measure of the progress which allows us to stop the step finding if several consecutive cycles provide no improvement
    r=2;
    LoopStatus='continue';

    while r<=NRound && strcmp(LoopStatus,'continue') %continue until Nround is reached, or convergence is achieved
        tWinCurrent = tWin+(r-1)*tWinIncrement; 
        [trans, phageData] = GhePhageTTest(phages, [av tWinCurrent Thr], phageDataInd(n), 'nothing'); %run this round of TTest
        Dwells{r} = GheConvertTransToDwells(trans);

        ShortestDwell = 0.05; %set the shortest dwell to 20 msec
        Nmin = round(ShortestDwell*band); %the minimum number of points in a dwell, this helps get rid of very short dwells identified by the algorythm
        MinStep = 2.5; %the smallest step is 2.5bp, to avoid fractured dwells due to flukes
        Dwells{r} = GheResolveShortDwells(phageData, Dwells{r}, Nmin, MinStep);
        Dwells{r} = GheCompareAgainstOldDwells(phageData, Dwells{r-1}, Dwells{r}, BinThr);
        Dwells{r} = GheResolveShortDwells(phageData, Dwells{r}, Nmin, MinStep);
        Dwells{r} = GheResolveShortDwells(phageData, Dwells{r}, Nmin, MinStep);
        Dwells{r} = GheResolveShortDwells(phageData, Dwells{r}, Nmin, MinStep);
        Progress(r)=GheAssessProgress(Dwells{r-1},Dwells{r});
        
        if Progress(r)==1
            disp(['Progress has been made in round #' num2str(r)]);
        else
            disp(['No Progress has been made in round #' num2str(r)]);
        end
        
        %figure; hold on;
        %set(gca,'Color',[1 1 1]);
        %plot(phageData.time, phageData.contour,'Color',[0.5 0.5 0.5]);
        %grid off;
        %GhePlotDwells(Dwells{r},phageData);
        %title([phageDataInd(n).file '; subtrace #' num2str(phageDataInd(n).stID) '; round #' num2str(r)]);
        %set(gcf, 'Position',[1 31 1920 1096]); %full screen figure

        %Progress is 0 if nothing changed, or 1 if the detected steps changed
        N=4;
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
    plot(phageData.time, phageData.contour,'Color',[0.5 0.5 0.5]);
    grid off;
    GhePlotDwells(Dwells{r},phageData);
    title([phageDataInd(n).file '; subtrace #' num2str(phageDataInd(n).stID) '; round #' num2str(r)]);
    %set(gcf, 'Position',[1 31 1920 1096]); %full screen figure
    
    %Update the stepsize values
    Dwells{end}.StepSize=[]; %empty it first
    for s=1:length(Dwells{end}.mean)-1
        Dwells{end}.StepSize(s)=Dwells{end}.mean(s+1)-Dwells{end}.mean(s);
        Dwells{end}.StepLocation(s)=(Dwells{end}.mean(s+1)+Dwells{end}.mean(s))/2;
    end
    %Update the Dwell Time values
    for d=1:length(Dwells{end}.mean)
        Dwells{end}.DwellTime(d)=(Dwells{end}.Npts(d)-1)/band; %the dwell times in seconds
    end
    
    %save this to the final data structure
    FinalDwells{n}=Dwells{end};
    FinalDwells{n}.File = phageDataInd(n).file; %file name
    FinalDwells{n}.TraceID = phageDataInd(n).stID; %trace ID
    FinalDwells{n}.Band = band; %bandwidth
    FinalDwells{n}.tTestThr = Thr; %bandwidth
    FinalDwells{n}.BinThr = BinThr; %binomial threshold
    
end
%save(SaveFile,'FinalDwells');
%disp(['Saved the dwell data to ' SaveFile]);