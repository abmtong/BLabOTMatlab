function StepFinding_GenerateDwellTimeStepSizeHistogram(MaxDwellTime)
% This script loads a user-specified StepFindingResults file and plots the
% step size histogram and the dwell-time histogram for steps between 8bp
% and 12bp
%
% You can now select multiple StepFindingResults files (27Jun2011)
%
% USE: StepFinding_GenerateDwellTimeStepSizeHistogram(MaxDwellTime)
%
% Gheorghe Chistol, 27 June 2011

MinBurst         = 8.5; %bp
MaxBurst         = 11.5; %bp
%MaxDwellTime     = 0.25; %sec
MaxXLim          = 2;
MaxStepSize      = 25; %bp
DwellBinSize     = MaxDwellTime/25; %sec
StepSizeBinSize  = 0.5; %bp
Nsim             = 2000; %number of simulations for Nmin calculation
DesiredConfidenceInterval = 0.95; %confidence interval for Nmin estimation

global analysisPath; 
[DataFile DataPath] = uigetfile([ [analysisPath filesep ] '*.mat'], 'Please select the Step Finding Results file','MultiSelect', 'on');
if ~iscell(DataFile)
    temp = DataFile;    clear DataFile;
    DataFile{1} = temp; clear temp;
end

%now go through the FinalDwells data structure and extract the step-sizes
StepSize  = []; %empty structure
DwellTime = []; 
for df=1:length(DataFile)
    clear FinalDwells FinalDwellsValidated; %to avoid conflict with old data
    load([DataPath filesep DataFile{df}]); %load the results file that has a list of step-sizes

    clear FinalDwells; FinalDwells = FinalDwellsValidated;
    
    for ph=1:length(FinalDwells) %ph indexes the phage
        for fc=1:length(FinalDwells{ph}) %fc indexes the feedback cycle
            if isfield(FinalDwells{ph}{fc},'StepSize')
                StepSize  = [StepSize  FinalDwells{ph}{fc}.StepSize]; %add the data from the current feedback cycle
            end

            if isfield(FinalDwells{ph}{fc},'DwellTime')
                DwellTime = [DwellTime FinalDwells{ph}{fc}.DwellTime(1:end-1)];
            end
        end
    end
end

% Look at Dwell-Times less than MaxDwellTime
KeepInd   = DwellTime<MaxDwellTime;
StepSize  = StepSize(KeepInd);
DwellTime = DwellTime(KeepInd);

%% Plot DwellTime Histogram
ValidBurstInd        = StepSize>MinBurst & StepSize<MaxBurst ;
DwellTime_ValidBurst = DwellTime(ValidBurstInd);

DwellTimeBins    = 0+DwellBinSize/2:DwellBinSize:MaxDwellTime;
figure; 
subplot(2,1,1); 
hold on; 
hist(DwellTime_ValidBurst, DwellTimeBins); h = findobj(gca,'Type','patch'); set(h,'FaceColor',0.8*[1 1 1]);
[N X] = hist(DwellTime_ValidBurst, DwellTimeBins);
[f x] = ksdensity(DwellTime_ValidBurst, DwellTimeBins);
f = f*sum(N)/sum(f); %scale the normalized probability density;
%plot(x,f,'r','LineWidth',2);
plot(0,0,'-r');
xlabel(['Dwells Before ' num2str(MinBurst) '-' num2str(MaxBurst) '-bp Bursts (s)']);
ylabel(['Count = ' num2str(length(DwellTime_ValidBurst))]);
title(DataFile ,'Interpreter','none');
set(gca,'XLim',[0 MaxXLim],'Box','on');

%% Calculate Nmin and its confidence interval using simulations
Nmin      = CalculateNminConfInt(DwellTime_ValidBurst, Nsim, DesiredConfidenceInterval);
MeanDwell = CalculateMeanDwellConfInt(DwellTime_ValidBurst, Nsim, DesiredConfidenceInterval);
Nmin
ConfInt     = round(DesiredConfidenceInterval*100); %in percent
legend(['Mean Dwell =' sprintf('%1.3f',MeanDwell(2)) 's (' num2str(ConfInt) '%: ' sprintf('%1.3f',MeanDwell(1)) '-' sprintf('%1.3f',MeanDwell(3)) ')' ], ...
       ['Nmin=' sprintf('%1.1f',Nmin(2)) ' (' num2str(ConfInt) '%: ' sprintf('%1.1f',Nmin(1)) '-' sprintf('%1.1f',Nmin(3)) ')']);


%% Generate the StepSize Histogram
StepSizeBins = 0+StepSizeBinSize/2:StepSizeBinSize:MaxStepSize+StepSizeBinSize;
%global N X;
[N X]        = hist(StepSize,StepSizeBins);

subplot(2,1,2); hold on;
hist(StepSize,StepSizeBins);
h = findobj(gca,'Type','patch'); set(h,'FaceColor',[0 164/255 1]);
xlabel('Step Size (bp)');
ylabel(['Count = ' num2str(length(StepSize))]);
set(gca,'XLim',[0 MaxStepSize],'Box','on');

%     x = X(X<14 & X>4);
%     y3 = 59*exp(-(x-3*2.4).^2/1.5^2);
%     y4 = 137*exp(-(x-4*2.4).^2/1.5^2);
%     plot(x,y3,'y',x,y4,'y','LineWidth',2);
%     plot(x,y3+y4,'m','LineWidth',2);

%% Save the image
%saveas(gcf,DataFile(1:end-4),'png');
%close gcf;