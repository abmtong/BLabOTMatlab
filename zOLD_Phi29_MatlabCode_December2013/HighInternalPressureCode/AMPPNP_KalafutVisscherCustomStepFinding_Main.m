function AMPPNP_KalafutVisscherCustomStepFinding_Main()
% This function finds steps around a selected PNP pause and saves the image
% and the step-results files. It is very similar to
% AMPPNP_CustomStepFinding (which relies on the t-test method) except that
% the current function uses the Schwartz information Criterion method
% described by Kalafut&Visscher.
%
% You will need an index file that contains info like this:
% 1) Processed Phage files (mat files)
% 2) An index file with instructions. Here's a sample index file:
%     070108N60 #16  220-228sec
%     070108N60 #17  230-235sec
%     070108N60 #18  237.5-241.5sec
%
% USE: AMPPNP_KalafutVisscherCustomStepFinding_Main()
%
% Gheorghe Chistol, 03 May 2011

%% Set the Analysis Path and the path for the Kalafut-Visscher method
global analysisPath;
if isempty(analysisPath)
    disp('analysisPath not defined. Use "SetAnalysisPath" to define it'); return;
end

addpath([pwd filesep 'KalafutVisscher_StepFinding' filesep], '-end'); %this is where the KV files are

%% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)',...
          'Filter Bandwidth (Hz)',...
          'Step Penalty Factor (3-5 is best)'};

Title = 'Enter the Following Parameters'; Lines = 1;
Default = {'2500','500','10'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
SampFreq      = str2num(Answer{1}); %sampling frequency
Bandwidth     = str2num(Answer{2}); %desired bandwidth after filtering, has to be an integer
PenaltyFactor = str2num(Answer{3}); %penalty factor, 1 is the default for SIC, but larger penalties dicourage overfitting

%% Load the Pause Index File (a bit more complicated than the standard index file)
IndexFile = uigetfile([ [analysisPath filesep] '*.txt'], 'Please select the AMPPNP Pause Index File','MultiSelect', 'off');
IndexFile = [analysisPath filesep IndexFile];
if ~exist(IndexFile,'file') %if no files were selected or file doesn't exist
    disp('No AMPPNP Index Files were selected'); return;
end
SaveFile = [IndexFile(1:end-4) '_AMPPNP_PauseResultsKV.mat'];
[SelectedPhages SelectedFeedbackCycles SelectedTStart SelectedTFinish] = AMPPNP_KalafutVisscherCustomStepFinding_LoadIndexFile(IndexFile);

%% Proceed to Find Steps
for p=1:length(SelectedPhages)
    %index p stands for "phage" 
    CurrentPhageFileName = [analysisPath filesep 'phage' SelectedPhages{p} '.mat'];
    
    if ~exist(CurrentPhageFileName,'file') %if the phage data file does not exist
        disp(['!!! Phage Data File does not exist: ' CurrentPhageFileName]);
    else %proceed to analyzing the data
        disp(['+ Analyzing Phage : ' CurrentPhageFileName ' FC = ' num2str(SelectedFeedbackCycles(p))]);
        load(CurrentPhageFileName); %Load the Current Phage Data file
        PhageData=stepdata; clear stepdata;%indexed data from the current trace

        %now define the region of interest based on the SelectedTStart and SelectedTFinish
        y = PhageData.contour{SelectedFeedbackCycles(p)};
        t = PhageData.time{SelectedFeedbackCycles(p)};

        %define the trace crop broundaries
        Tstart = SelectedTStart(p);
        Tstop  = SelectedTFinish(p);
        
        KeepersInd = t<Tstop & t>Tstart; %the index of points to keep
        t = t(KeepersInd);
        y = y(KeepersInd);
        
        %plug the cropped data back into the structure, will be used later
        PhageData.contour{SelectedFeedbackCycles(p)} = y; 
        PhageData.time{SelectedFeedbackCycles(p)}    = t;

        AvgNum = round(SampFreq/Bandwidth);  %averaging number
        disp(['... Filter Bandwidth : ' num2str(round(Bandwidth)) ' Hz']);
        y = FilterAndDecimate(y,AvgNum);
        t = FilterAndDecimate(t,AvgNum);
            
        %proceed to find steps and others
        if abs(t(end)-t(1))>0.5 %only work if you have more than 0.5sec worth of data
            AverageVelocity      = abs((y(1)-y(end))/(t(1)-t(end)));
            CurrentFeedbackCycle = SelectedFeedbackCycles(p);
            PhageData.contourFiltered{CurrentFeedbackCycle} = y;
            PhageData.timeFiltered{CurrentFeedbackCycle}    = t;
            clear Dwells; %clear some variables to avoid conflict

            [StepInd DwellInd] = KV_FindSteps(t,y,PenaltyFactor,1); %1 is the PlotOption, meaning that I want the results to be plotted
            fc = 1; %there is only one feedback cycle at a time
            %now re-format the results in a way that is consistent with our previous formatting from adaptive t-test calculations
            for d=1:length(DwellInd)
                ContData = PhageData.contourFiltered{CurrentFeedbackCycle}(DwellInd(d).Start:DwellInd(d).Finish); %contour data
                TimeData = PhageData.timeFiltered{CurrentFeedbackCycle}(DwellInd(d).Start:DwellInd(d).Finish); %time data
                FinalDwells{p}{fc}.start = DwellInd(d).Start;
                FinalDwells{p}{fc}.end   = DwellInd(d).Finish;
                FinalDwells{p}{fc}.mean  = mean(ContData);
                FinalDwells{p}{fc}.std   = std(ContData);
                FinalDwells{p}{fc}.Npts  = length(ContData);
                FinalDwells{p}{fc}.StepSize     = []; %will calculate this later
                FinalDwells{p}{fc}.StepLocation = [];%will calculate this later
                FinalDwells{p}{fc}.DwellTime      = range(TimeData);
                FinalDwells{p}{fc}.DwellLocation  = mean(ContData);
            end

            for s=1:length(DwellInd)-1 %we can't calculate the step-size after the last dwell
                FinalDwells{p}{fc}.StepSize(s)     = DwellInd(s+1).Mean - DwellInd(s).Mean;
                FinalDwells{p}{fc}.StepLocation(s) = (DwellInd(s+1).Mean - DwellInd(s).Mean)/2; %where along DNA did this step occur?
            end
             %save this to the final data structure
             FinalDwells{p}{fc}.PhageFile     = CurrentPhageFileName; %file name
             FinalDwells{p}{fc}.FeedbackCycle = CurrentFeedbackCycle; %trace ID
             FinalDwells{p}{fc}.Band          = Bandwidth; %bandwidth
             FinalDwells{p}{fc}.tTestThr      = NaN; 
             FinalDwells{p}{fc}.BinThr        = NaN;
             disp('--------------------------------------------------------');

             title([PhageData.file '; Feedback Cycle #' num2str(CurrentFeedbackCycle) '; ' ...
                    'AvgVel:' num2str(round(AverageVelocity)) 'bp/sec; ' ...
                    'Bandwidth:' num2str(round(Bandwidth)) 'Hz; Kalafut-Visscher Method']);

             %Save the current figure as an image in a folder for later 
             ImageFolderName=[analysisPath filesep 'AMPPNP_StepFindingResultsKV_Images'];

             if ~isdir(ImageFolderName);
                 mkdir(ImageFolderName);%create the directory
             end
             
             temp = sprintf('%3.1f',Tstart);
             StartText = [sprintf('%3.0f',Tstart) 'p' temp(end)];
             temp = sprintf('%3.1f',Tstop);
             StopText  = [sprintf('%3.0f',Tstop) 'p' temp(end)];
             Appendix = [StartText '_' StopText];
             
             %safe a FIG image
             ImageFileName = [ImageFolderName filesep PhageData.file(1:end-4) '_' num2str(CurrentFeedbackCycle) '_' Appendix '.fig'];
             saveas(gcf,ImageFileName);
             
             %safe a PNG image
             ImageFileName = [ImageFolderName filesep PhageData.file(1:end-4) '_' num2str(CurrentFeedbackCycle) '_' Appendix '.png'];
             saveas(gcf,ImageFileName);
             
             %close the figure;
             close(gcf);
        else
            disp(['! Feedback Cycle #' num2str(CurrentFeedbackCycle) 'because it contains insuficient data']);
        end
    end
end

save(SaveFile,'FinalDwells');
disp(['Saved stepping data to ' SaveFile]);
return;