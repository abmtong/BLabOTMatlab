function PlotMultipleCroppedTracesSeparateFigures(F, SaveMode)
% This function plots multiple (or just one) phage traces using the crops
% defined in the *.crop files. It plots each trace on a separate figure
% SaveMode = 'png';
% USE: PlotMultipleCroppedTracesSeparateFigures(F, SaveMode)
%
% Gheorghe Chistol, 23 Aug 2010

global analysisPath;
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.');
    return;
end

%% Define Parameters
Bandwidth = 2500;
if nargin==0
    %no filtering frequency was specified
    F=200; %set the filtering frequency to 100Hz by default
    disp('No Filter Frequency was specified, F=100Hz by default');
    SaveMode = 'none'; %no saving
elseif nargin==1
    SaveMode = 'none';
end

% Make sure that the Filter Frequency is positive, integer, round if neccessary
if rem(Bandwidth,F)~=0 || ~isinteger(F)
    N=round(Bandwidth/F); %this is the filtering factor
    %this is done to make sure that Bandwidth is divisible by N
    disp(['Filtering data to ' num2str(Bandwidth/N) ' Hz']);
else
    disp('The Filter Frequency has to be a positive, integer number');
    return;
end

%% Select the phage files of interest
File = uigetfile([ [analysisPath '\'] 'phage*.mat'], 'MultiSelect', 'on');
if isempty(File) %if no files were selected
    disp('No *.mat phage files were selected');
    return;
end

if ~iscell(File) %if there is only one file, make it into a cell, for easier processing later
    temp=File; clear File; File{1}=temp;
end
for i=1:length(File)
    CropFile = [analysisPath '\CropFiles\' File{i}(6:end-4) '.crop']; % this is the complete address of the crop file that should 
                                                         % correspond to the current phage *.mat file
    if exist(CropFile,'file') %check if the crop file exists, if it doesn't, don't process the phage file at all
        load([analysisPath '\' File{i}]); %load a single specified phage file
        Trace = stepdata; clear stepdata; %load the data and clear intermediate data
        
        FID = fopen(CropFile); %open the *.crop file
        Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
        Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
        fclose(FID);
        
        %go through each subtrace and filter it
        Contour = []; %unified data - one vector for the entire trace
        Time    = []; %unified time - one vector for the entire trace
        Force   = []; %unified force - one vector for the entire trace
        figure('PaperPosition',[0.5 .5 6 8]); hold on;
        xlabel('Time (sec)');
        ylabel('DNA Tether Length (bp)');
        title([File{i}],'Interpreter','none','FontWeight','bold');

        for n=1:length(Trace.time)
            TempTime    = FilterAndDecimate(Trace.time{n}, N); %filter the time and the other important values
            TempContour = FilterAndDecimate(Trace.contour{n}, N);
            %TempForce   = FilterAndDecimate(Trace.force{n}, N);
            KeepInd = TempTime>Tstart & TempTime<Tstop;
            x = TempTime(KeepInd);
            y = TempContour(KeepInd);
            if ~isempty(x)
                plot(x,y,'m');
            end
        end
        set(gca,'Box','on');
        if strcmp(SaveMode,'png');
           saveas(gcf,[analysisPath filesep File{i}(6:end-4) '.png']);
        end
    else
        %the Crop *.crop file doesn't exist, skip the corresponding trace
        disp([File{i} ' was skipped because it has no crop (*.crop) file']);
    end %end of IF
end %end of FOR
end