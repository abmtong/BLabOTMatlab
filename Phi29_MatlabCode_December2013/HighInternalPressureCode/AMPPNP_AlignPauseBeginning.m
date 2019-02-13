function AMPPNP_AlignPauseBeginning()
% This program uses the results generated by AMPPNP_CustomStepFinding
% It aligns the beginning of the AMP-PNP pause for all traces.
%
% Gheorghe Chistol, 3 Mar 2011

%% Set the Analysis Path
global analysisPath;
if isempty(analysisPath)
    disp('analysisPath not defined. Use "SetAnalysisPath" to define it'); return;
end

%% Load the File with StepSize results
ResultsFile = uigetfile([ [analysisPath '\'] '*_AMPPNP_Pause_Results.mat'], 'Please select the AMPPNP Pause StepSize Results File','MultiSelect', 'off');
ResultsFile = [analysisPath '\' ResultsFile];
if ~exist(ResultsFile,'file') %if no files were selected or file doesn't exist
    disp('No AMPPNP results file was found'); return;
else
    load(ResultsFile); %loaded the results file
end

% FinalDwells{p}{1}.          %p is the pause index, 1 is there to keep it in a form compatible with other functions
%                     start: [1 53 75 108 139 620 631 654 688]
%                       end: [52 74 107 138 619 630 653 687 799]
%                      mean: [2.1320e+003 2.1231e+003 2.1133e+003 2.1065e+003 2.0990e+003 2.0923e+003 2.0870e+003 2.0763e+003 2.0687e+003]
%                       std: [2.4637 2.4089 2.2739 2.1306 2.2954 1.8642 2.1584 2.2686 1.4421]
%                      Npts: [52 22 33 31 481 11 23 34 112]
%                  StepSize: [-8.8619 -9.8639 -6.8329 -7.5028 -6.6766 -5.2661 -10.7543 -7.5308]
%              StepLocation: [2.1276e+003 2.1182e+003 2.1099e+003 2.1027e+003 2.0956e+003 2.0896e+003 2.0816e+003 2.0725e+003]
%                 DwellTime: [0.5100 0.2100 0.3200 0.3000 4.8000 0.1000 0.2200 0.3300 1.1100]
%             DwellLocation: [2.1320e+003 2.1231e+003 2.1133e+003 2.1065e+003 2.0990e+003 2.0923e+003 2.0870e+003 2.0763e+003 2.0687e+003]
%                 PhageFile: 'C:\GheLaptop_D_AfterCrash19Feb2011\Phi29\2010_ANALYSIS\AMP-PNP_Experiments\Old_AMPPNP_Traces_2009\phage070108N60.mat'
%             FeedbackCycle: 16
%                      Band: 100
%                  tTestThr: 0.0045
%                    BinThr: 0.0050
%% Loop through all the results, construct the x-y stepping plot and align them
%figure('Units','normalized','Position',[0 0.04 1 0.87]); hold on;
%xlabel('Time (sec)'); ylabel('Contour Length Changes (bp)');
StepBefore=[];
StepAfter =[];
AllSteps = [];
for p=1:length(FinalDwells) %p is the pause trace index
    CurrPauseData = AMPPNP_MergeFracturedBursts(FinalDwells{p}{1},7,11,0.5); %this will merge steps that are less than say 6bp and add up to no more than 11bp, while being separated by no more than 0.1sec
    BeforeMergingData = FinalDwells{p}{1};
    
    AllSteps = [AllSteps -CurrPauseData.StepSize];
    x=[]; y=[]; %these are used for plotting only, clear them
    X=[]; Y=[];
    for d=1:length(CurrPauseData.DwellLocation) %d is the dwell index
       deltaT=1/CurrPauseData.Band; %time increment from point to point
       x(end+1:end+2)=[CurrPauseData.start(d) CurrPauseData.end(d)]*deltaT; %time coordinates for the current dwell
       y(end+1:end+2)=[1 1]*CurrPauseData.DwellLocation(d); %y coordinates for the current dwell
    end
    
    for d=1:length(BeforeMergingData.DwellLocation)
       X(end+1:end+2)=[BeforeMergingData.start(d) BeforeMergingData.end(d)]*deltaT; %time coordinates for the current dwell
       Y(end+1:end+2)=[1 1]*BeforeMergingData.DwellLocation(d); %y coordinates for the current dwell
    end
    %figure; hold on;
    %plot(x,y,'-g',X,Y,':k','LineWidth',2);
    
    %now that we have the x-y plot constructed, we need to offset
    %everything such that the beginning of the AMPPNP pause is at the
    %origin in all cases. We take the longest dwell in the trace to be our
    %AMP-PNP pause
    PauseInd = find(CurrPauseData.DwellTime==max(CurrPauseData.DwellTime));
    if length(PauseInd)==1 %we're good
        StepBefore(p) = -CurrPauseData.StepSize(PauseInd-1);
        StepAfter(p)  = -CurrPauseData.StepSize(PauseInd);
        
        xOffset = CurrPauseData.start(PauseInd)*deltaT;
        yOffset = CurrPauseData.DwellLocation(PauseInd);
        x=x-xOffset;
        y=y-yOffset;
        %plot(x,y,'b');
    end
end

Max=15;
Min=0;
BinSize=.5;
Bins = Min+BinSize/2:BinSize:Max-BinSize/2;
figure('Units','normalized','Position',[0 0.04 0.3 0.87]); hold on;
subplot(3,1,1);
temp=StepBefore; 
temp=temp(temp<Max & temp>Min);
[fBefore xBefore]=ksdensity(temp);
hist(temp,Bins);
title('StepBeforeHist'); set(gca,'XLim',[Min Max]);

subplot(3,1,2);
temp=StepAfter;
temp=temp(temp<Max & temp>Min);
[fAfter xAfter]=ksdensity(temp);
hist(temp,Bins);
title('StepAfterHist'); set(gca,'XLim',[Min Max]);

%subplot(4,1,3);
temp=StepBefore+StepAfter;
temp=temp(temp<Max & temp>Min);
[fSum xSum]=ksdensity(temp); 
%hist(temp,Bins);
%title('Sum Of Step Before+After Hist'); set(gca,'XLim',[0 25]);

subplot(3,1,3)
temp=AllSteps;
temp=temp(temp<Max & temp>Min);
[fAll xAll]=ksdensity(temp); 
hist(temp,Bins);
title('AllStepsHist'); set(gca,'XLim',[Min Max]);

figure;
plot(xBefore,fBefore,'-b',...
     xAfter,fAfter,'-r',...
     xSum,fSum,':b',...
     xAll,fAll,'-k','LineWidth',2);
legend('StepBefore','StepAfter','StepBefore+StepAfter','AllSteps');
xlabel('StepSize (bp)');
ylabel('Probability Density');