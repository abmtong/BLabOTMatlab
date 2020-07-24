% Useful scripts for calculating dwell time distributions and 
% displaying the results
% Jeff Moffitt: Feb 20, 2008
% Gheorghe Chistol: Nov 19, 2008

clear all; close all;
%% Add the Path where most files are stored
path('C:\Documents and Settings\Phi29\Desktop\MatlabCode\MatlabFilesGhe\MatlabGeneral\NewAnalysisCode\',path);
%the step finding scripts and functions are stored in a separate folder

%% Load Phages, calculate velocities, and index appropriately
SetAnalysisPath();
phages = LoadPhage();
phageData = PhageVelocity(phages);
phageDataInd = LoadPhageList(phageData);

%% Set Parameters
fsamp = 2500;     %sampling frequency
band = 250;       %bandwidth (after downsampling)?
av = fsamp/band;  %averaging number,
tWin = 10;        %time window size (number of points used to calculate the Ttest)  
thresh = 1e-4;    %tresholod for the T-Test
col = 'b';
binMult = 1;

%% Initial round of Step Finding
%the steps were found using the Ttest algorythm with a very large window
%size, three times the original window size 3*tWin
thresh=1e-4;
[trans, phageData] = GhePhageTTest(phages, [av tWin thresh], phageDataInd, 'nothing');
IndexedData=phages(1);
IndexedData.time = IndexedData.time(phageDataInd(1).stID);
IndexedData.contour = IndexedData.contour(phageDataInd(1).stID);
IndexedData.force = IndexedData.force(phageDataInd(1).stID);
IndexedData.forceX_err = '';
IndexedData.forceY_err = '';
IndexedData.trapX = '';
IndexedData.trapY = '';

close all; figure; hold on;
plot(phageData(1).time, phageData(1).contour,'b');
plot(phageData(1).timeFit, phageData(1).contourFit,'k');



%%
clear dwells;
NRound = 2;
BinThresh = 0.005; %binomial threshold, half a percent
tWinIncrement = 5; %increment in Window size for each round of TTest analysis
%run NRound rounds of Ttest step analysis with gradually increasing window
%size. After each round go through the tentative steps and do a consistency check with binomial analysis 
phageDataPrev = phageData; %save the phageData from the previous round of analysis
tWin=10;
[trans, phageData]=GheRoundTTestRun(phages, av, tWin, thresh, phageDataInd(1)); %run this round of TTest
dwells = GheConvertTransToDwells(trans);
dwellsPrev = dwells; %save the dwell information from the previous round of analaysis
traceID = 1; %the Id of the current phage trace
%Come back and make sure that the Ttest outputs the decimated contours of
%the 

for r=1:NRound
    tWinCurrent = tWin+(r-1)*tWinIncrement; 
    [trans, phageData]=GheRoundTTestRun(phages, av, tWinCurrent, thresh, phageDataInd(1)); %run this round of TTest
    dwells = GheConvertTransToDwells(trans);

    %consider each step identified in the previous round
    %look inside and see how many substeps were identified in the current
    %round
    %ps = previous round step index
    %cs = current round step index within the ps, 
    %each ps contains one or more cs
    %for now the specified transitions are only tentative
    %perform binomial consistency analysis 
    dwells = GheCheckAllCurrentDwells(phageData(traceID), dwellsPrev(traceID), dwells(traceID), BinThresh); 
%[trans(traceID)] = 
    
%    Refresh; %the current tentative steps that are consistent with binomial analysis, are now promoted to full steps
                 %any tentative steps shorter than tWin will be declared
                 %null
%    GheConsecutiveStepAnalysis; % check if consecutive steps are indeed independent steps, sometimes they may be one
%    Refresh; %update all current steps and promote them to the rank of fully defined steps
        %Proceed to the next round of binomial analysis
end %end for R=1:NRound



%[dwelltime_all, stepsize_select_all, std_select_all, wid_all, trans, phageData, contour] = ...
%    GhePhageTTest(phages, [av tWin+40 thresh], phageDataInd, 'nothing');
%plot(phageData(1).tfit, phageData(1).xfit,'r');

% 
% %% Plot the Tvalue and SGN
% close all;
% figure;
% subplot(2,1,1)
%     plot(gca,tempX,tempY,'Color',[.5 .5 .5]); %plot the raw data
%     hold on;
%     plot(gca,tempXfit,tempYfit,'Color',[0 0 0]); %plot the stepping pattern data
% %subplot(3,1,2)
% %	plot(phageData.tfit,phageData.t,'k');
% subplot(2,1,2)
% 	plot(phageData.tfit,phageData.sgn,'k');
%     hold on;
%     x = phageData.tfit;
%     y = thresh*ones(1,length(x));
%     plot(x,y,'b'); clear x y;
%     axis([218 232 0 0.0005]);
% 
