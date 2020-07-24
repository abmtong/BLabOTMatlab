function PlotMultipleCroppedTraces_UniformSpacing()
% This function plots multiple (or just one) phage traces using the crops
% defined in the *.crop files. This allows us to view only the useful
% portions of traces. Note that only the traces that have a corresponding
% *.crop file will be plotted.
% This version works well for low filling traces that can be fitted to a straight line
%
% USE: PlotMultipleCroppedTraces_UniformSpacing()
%
% Gheorghe Chistol, 30 Nov 2012

PlotOption='none';
global analysisPath;

%% Define Parameters
Bandwidth = 2500;
F         = 200; %for plotting the preview data
N         = round(Bandwidth/F); %this is the filtering factor
FitPts    = 100; %# of pts to be used for fitting a line to the trace
DeltaT    = 3; %in seconds, time separation between consecutive traces 

%% Select the phage files of interest
File = uigetfile([ [analysisPath '\'] 'phage*.mat'], 'MultiSelect', 'on');
if isempty(File) %if no files were selected
    disp('No *.mat phage files were selected'); return;
end

if ~iscell(File) %if there is only one file, make it into a cell, for easier processing later
    temp=File; clear File; File{1}=temp;
end

PlotCount=0; %number of traces plotted
FigureHandle=figure; hold on;
xlabel('Time (sec)'); ylabel('DNA Tether Length (bp)');

for i=1:length(File)
    CropFile = [analysisPath '\CropFiles\' File{i}(6:end-4) '.crop']; % this is the complete address of the crop file that should 
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
        for n=1:length(Trace.time)
            TempTime    = FilterAndDecimate(Trace.time{n}, N); %filter the time and the other important values
            TempContour = FilterAndDecimate(Trace.contour{n}, N);
            TempForce   = FilterAndDecimate(Trace.force{n}, N);
            
            Time    = [Time    TempTime];
            TempSize=size(TempContour);
            if TempSize(1)==1
                Contour = [Contour TempContour]; %#ok<*AGROW>
                Force   = [Force   TempForce];
            else
                Contour = [Contour TempContour']; %#ok<*AGROW>
                Force   = [Force   TempForce'];
            end
        end
        TimeLimits=[Tstart Tstop];
        Ind = Time>Tstart & Time<Tstop;
        Time = Time(Ind);
        Contour = Contour(Ind);
        Force   = Force(Ind);
        Time    = Time-Time(1);
        
        % figure out the offset of the current  trace.
        FitN       = round(length(Time)/FitPts);
        FitTime    = FilterAndDecimate(Time,    N);
        FitContour = FilterAndDecimate(Contour, N);
        FitParam       = polyfit(FitTime,FitContour,1);
        InterceptX     = -FitParam(2)/FitParam(1);
        CurrTimeOffset = PlotCount*DeltaT-InterceptX;
        Time           = Time+CurrTimeOffset;
        
        %plot the trace with an offset in time, for better viewing
        plot(Time,Contour,'b','MarkerSize',1);%,'MarkerSize',3);
        text(double(Time(1)),double(Contour(1)),File{i}(6:end-4),'FontSize',8,'Color','k');
        set(gca,'Color','w'); %set(h,'FontSize',8);
        PlotCount=PlotCount+1;
    else
        %the Crop *.crop file doesn't exist, skip the corresponding trace
        disp([File{i} ' was skipped because it has no crop (*.crop) file']);
    end %end of IF
end %end of FOR

%% If no traces were plotted, close the figure since it's empty
if PlotCount==0;
    close(FigureHandle);
end
