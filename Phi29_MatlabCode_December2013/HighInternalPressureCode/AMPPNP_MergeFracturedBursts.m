function MergedStepData = AMPPNP_MergeFracturedBursts(OriginalStepData,MaxStep,MaxBurst,MaxDwellBetween)
% This function will take a standard StepSizeResults structure and go
% through it, merging consecutive steps of at most MaxStepSize and
% separated by at most MaxTimeSeparation while yielding bursts smaller than
% MaxBurstSize
%
%     OriginalStepData = 
% 
%                 start: [1 53 75 108 139 620 631 654 688]
%                   end: [52 74 107 138 619 630 653 687 799]
%                  mean: [1x9 double]
%                   std: [2.4637 2.4089 2.2739 2.1306 2.2954 1.8642 2.1584 2.2686 1.4421]
%                  Npts: [52 22 33 31 481 11 23 34 112]
%              StepSize: [-8.8619 -9.8639 -6.8329 -7.5028 -6.6766 -5.2661 -10.7543 -7.5308]
%          StepLocation: [2.1276e+003 2.1182e+003 2.1099e+003 2.1027e+003 2.0956e+003 2.0896e+003 2.0816e+003 2.0725e+003]
%             DwellTime: [0.5100 0.2100 0.3200 0.3000 4.8000 0.1000 0.2200 0.3300 1.1100]
%         DwellLocation: [1x9 double]
%             PhageFile: [1x116 char]
%         FeedbackCycle: 16
%                  Band: 100
%              tTestThr: 0.0045
%                BinThr: 0.0050
%
% USE:  MergedStepData = AMPPNP_MergeFracturedBursts(OriginalStepData,MaxStep,MaxBurst,MaxDwellBetween)
%
% Gheorghe Chistol, 3 Mar 2011

DwellStart    = OriginalStepData.start;
DwellEnd      = OriginalStepData.end;
DwellNpts     = OriginalStepData.Npts;
StepSize      = -OriginalStepData.StepSize; %this way the step size is positive
DwellLocation = OriginalStepData.DwellLocation;
DwellTime     = OriginalStepData.DwellTime;
Bandwidth     = OriginalStepData.Band;
deltaT        = 1/Bandwidth; %time separation between each filtered data point

s=1;
while s<length(StepSize)-1
    CurrStep     = StepSize(s);
    NextStep     = StepSize(s+1);
    DwellBetween = DwellTime(s+1); 
    
    if CurrStep<MaxStep && NextStep<MaxStep && DwellBetween<MaxDwellBetween && CurrStep+NextStep<MaxBurst
        %the current step and the next step can be merged
        StepSize(s)=CurrStep+NextStep;
        StepSize(s+1)=[]; %remove that entry, it has been absorbed into the current merged step
        DwellTime(s)=DwellTime(s)+DwellTime(s+1); %merge current dwell with the next dwell
        DwellTime(s+1)=[]; %remove that entry
        DwellLocation(s+1)=[]; %next dwell location removed due to merge
        %the merged dwell now begins where the (s)th dwell used to begin
        %and ends where the (s+1)th dwell used to end
        DwellStart(s+1) = [];
        DwellEnd(s)     = [];
        DwellNpts(s)    = DwellNpts(s)+DwellNpts(s+1); %due to merging
        DwellNpts(s+1)  = [];
        %disp(['Merged another pair ' num2str(CurrStep) 'bp and ' num2str(NextStep) 'bp']);
        s=s+1;
    else
        s=s+1; %no merging occured, move on
    end
end

%now organize the merged results in a proper form
MergedStepData.start = DwellStart; 
MergedStepData.end = DwellEnd;
MergedStepData.Npts = DwellNpts;
MergedStepData.StepSize = -StepSize; %going back to negative step sizes since the tether is getting shorter
MergedStepData.DwellLocation = DwellLocation;
MergedStepData.DwellTime = DwellTime;
MergedStepData.PhageFile = OriginalStepData.PhageFile;
MergedStepData.FeedbackCycle = OriginalStepData.FeedbackCycle;
MergedStepData.Band = OriginalStepData.Band;