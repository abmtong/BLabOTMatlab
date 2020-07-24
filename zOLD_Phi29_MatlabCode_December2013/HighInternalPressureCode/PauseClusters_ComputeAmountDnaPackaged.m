function ResultsDnaPackaged = PauseClusters_ComputeAmountDnaPackaged()
% This function lets you select a bunch of phage######N## files and
% computes the total amt of DNA packaged in these traces. Note that this
% function will only look at the traces that have a CROP-file and will only
% consider the amt of DNA packaged within the crop region
%
% USE: ResultsDnaPackaged = PauseClusters_ComputeAmountDnaPackaged()
%
% Gheorghe Chistol, 27 May 2011

%% Define basic parameters
global analysisPath;
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.'); return;
end

FilterFactor = 25; %filter from 2500Hz down to 100Hz

%% Select the phage files of interest
[TraceFiles TraceFolder] = uigetfile([ [analysisPath filesep] 'phage*.mat'], 'MultiSelect', 'on');
if isempty(TraceFiles) %if no files were selected
    disp('No *.mat phage files were selected'); return;
end

if ~iscell(TraceFiles) %if there is only one file, make it into a cell, for easier processing later
    temp=TraceFiles; clear TraceFiles; TraceFiles{1}=temp; clear temp;
end

%Initialize the results data structure
ResultsDnaPackaged.TotalDnaPackaged   = 0;
ResultsDnaPackaged.PhageTraceFiles    = [];
ResultsDnaPackaged.PhageCropFiles     = [];
ResultsDnaPackaged.DnaPackagedByPhage = [];
ResultsDnaPackaged.PhageFolder        = TraceFolder;

for i=1:length(TraceFiles)
    CropFile = [TraceFolder filesep 'CropFiles' filesep TraceFiles{i}(6:end-4) '.crop'];
    
    if exist(CropFile,'file') %don't process the phage trace if crop file doesn't exist
        load([TraceFolder filesep TraceFiles{i}]); %load a single specified phage file
        Trace = stepdata; clear stepdata; %load the data and clear intermediate data
        
        FID = fopen(CropFile); %open the *.crop file
        Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
        Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
        fclose(FID);
        
        Contour = []; %unified data - one vector for the entire trace
        Time    = []; %unified time - one vector for the entire trace

        for n=1:length(Trace.time)
            Time    = [Time    FilterAndDecimate(Trace.time{n},    FilterFactor)];
            Contour = [Contour FilterAndDecimate(Trace.contour{n}, FilterFactor)];
        end
        
        KeepInd = Time>Tstart & Time<Tstop; %index of data within the crop window
        Time    = Time(KeepInd);
        Contour = Contour(KeepInd);
        
        ResultsDnaPackaged.TotalDnaPackaged          = ResultsDnaPackaged.TotalDnaPackaged+range(Contour);
        ResultsDnaPackaged.PhageTraceFiles{end+1}    = TraceFiles{i};
        ResultsDnaPackaged.PhageCropFiles{end+1}     = CropFile;
        ResultsDnaPackaged.DnaPackagedByPhage(end+1) = range(Contour);
        
        disp(['Succesfully processed ' TraceFiles{i}]);
    else
        %the Crop *.crop file doesn't exist, skip the corresponding trace
        disp([TraceFiles{i} ' was skipped because it has no crop (*.crop) file']);
    end
end