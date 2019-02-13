function PreviewCroppedTrace_ContourVsTime_ForceVsTime()
% This function plots a single phage trace that has been previously cropped (i.e. posseses an
% associated *.crop file). It displays both Contour vs Time and Force vs Time.
%
% USE: PreviewCroppedTrace_ContourVsTime_ForceVsTime()
%
% Gheorghe Chistol, 26 Sept 2012

PlotOption='none';
global analysisPath;
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.');
    return;
end

%% Define Parameters
Bandwidth     = 2500;
F = 200;
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
    CropFile = [analysisPath '\CropFiles\' File{i}(6:end-4) '.crop']; % this is the complete address of the crop file
    if exist(CropFile,'file') %check if the crop file exists, if it doesn't, don't process the phage file at all
        load([analysisPath '\' File{i}]); %load a single specified phage file
        Trace = stepdata; clear stepdata; %load the data and clear intermediate data
        
        FID = fopen(CropFile); %open the *.crop file
        Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
        Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
        fclose(FID);
        
        Time    = [];
        Contour = [];
        Force   = [];
        for n=1:length(Trace.time) %go through each subtrace and filter it
            TempTime    = FilterAndDecimate(Trace.time{n}, N); %filter the time and the other important values
            TempContour = FilterAndDecimate(Trace.contour{n}, N);
            TempForce   = FilterAndDecimate(Trace.force{n}, N);
            KeepInd = TempTime>Tstart & TempTime<Tstop;
            Time    = [Time TempTime(KeepInd)];
            Contour = [Contour TempContour(KeepInd)];
            Force   = [Force TempForce(KeepInd)];
        end
        
        figure; 
        [AX,H1,H2] = plotyy(Time,Contour,Time,Force,'plot');

        title(File{i}(6:end-4));
        set(gca,'Color','w');
        TimeLimits = [Tstart-0.05*range([Tstart Tstop]) Tstop+0.05*range([Tstart Tstop])];
        set(AX(1),'XLim',TimeLimits);
        set(AX(2),'XLim',TimeLimits);
        set(get(AX(1),'Ylabel'),'String','DNA Contour Length (bp)');
        set(get(AX(2),'Ylabel'),'String','Tether Force (pN)'); 
        xlabel('Time (s)')
    else
        %the Crop *.crop file doesn't exist, skip the corresponding trace
        disp([File{i} ' was skipped because it has no crop (*.crop) file']);
    end %end of IF
end %end of FOR