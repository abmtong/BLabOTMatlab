function CalculateVelocities(PlotOption)
% This function requires *.mat and the corresponding *.crop files. It
% calculates the velocity single or multiple phage traces at once. It was
% written to investigate whether ATP binding is affected in the late stages
% of packaging. All data is saved in the AnalysisFolder\VelocityData\
% The most important saved data are: Velocity (vector), Location (vector)
%                                    and Parameters (structure)
%
% It requires the following parameters:
% Filtered Frequency (Hz):  data is filtered down to this freq to reduce noise
% Hist Lower Limit:         lower limit of the histogram, for consistent plotting
% Hist Upper Limit:         upper limit of the histogram, for consistent plotting
% Hist Bin Width:           width of the histogram bins, for consistent plotting
%
% USE: CalculateVelocities()
%
% Gheorghe Chistol, 21 Jun 2010
% edited            18 Aug 2010
% edited            24 Aug 2010

if nargin==0
    PlotOption='none'; %don't plot anything unless the user says so
end

global analysisPath;
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.');
    return;
end

%% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)','Filtered Frequency (Hz)','Velocity Window Length (bp)', 'Hist Lower Limit (bp/sec)','Hist Upper Lim (bp/sec)','Hist Bin Width (bp/sec)'};
Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'2500','10','50','-150','50','2'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth     = str2num(Answer{1});
F             = str2num(Answer{2}); %this is the desired filter frequency
VelWinLength  = str2num(Answer{3}); %the # of bp used to calculate one velocity point
HistLowerLim  = str2num(Answer{4});
HistUpperLim  = str2num(Answer{5});
HistBinWidth  = str2num(Answer{6});

Parameters.Bandwidth    = Bandwidth;
Parameters.F            = F;
Parameters.VelWinLength = VelWinLength;
Parameters.Comments     = 'F is the frequency to which the data is filtered; VelWinLength is the size of the window (in bp) that is used to calculate vel';

%% Make sure that the Filter Frequency is positive, integer, round if neccessary
if rem(Bandwidth,F)~=0 || ~isinteger(F)
    N=round(Bandwidth/F); %this is the filtering factor
    %this is done to make sure that Bandwidth is divisible by N
    disp(['Filtering data to ' num2str(Bandwidth/N) ' Hz']);
else
    disp('The Filter Frequency has to be a positive, integer number');
    return;
end

%% Select the phage files of interest
File = uigetfile([ [analysisPath '\'] '*.mat'], 'MultiSelect', 'on');
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
        disp('--------------------');        
        disp([File{i} ' is being processed now']);
        load([analysisPath '\' File{i}]); %load a single specified phage file
        Trace = stepdata; clear stepdata; %load the data and clear intermediate data
        
        FID = fopen(CropFile); %open the *.crop file
        Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
        Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time

        FiltTrace.File=Trace.file; %keep the filename
        %go through each subtrace and filter it
        Contour = []; %unified data - one vector for the entire trace
        Force = []; %unified force - one vector for the entire trace
        Time    = []; %unified time - one vector for the entire trace
        for n=1:length(Trace.time)
            FiltTrace.Time{n} = FilterAndDecimate(Trace.time{n}, N); %filter the time and the other important values
            FiltTrace.Contour{n} = FilterAndDecimate(Trace.contour{n}, N);
            FiltTrace.Force{n} = FilterAndDecimate(Trace.force{n}, N);
            
            Time     = [Time    FiltTrace.Time{n}];
            TempSize = size(FiltTrace.Contour{n});
            if TempSize(1)==1
                Contour = [Contour FiltTrace.Contour{n}]; %#ok<*AGROW>
                Force   = [Force   FiltTrace.Force{n}];
            else
                Contour = [Contour FiltTrace.Contour{n}']; %#ok<*AGROW>
                Force   = [Force   FiltTrace.Force{n}'];
            end
        end
        TimeLimits=[Tstart Tstop];        
        %% Go through each subtrace and break ip up into smaller fragments.
        %Fit a straight line through those fragments and save the vel data
        Vel.Velocity = []; %velocity value
        Vel.Location = []; %location where velocity was measured
        Vel.Force    = []; %the average force across the segment
        Vel.Segment  = []; %the length of the segment across which the velocity was calculated (in bp)
        
        Ind = 1:length(Time); %total index of the time vector
        Ind(Time>Tstop)=[]; %remove the points outside the time crop region
        Ind(Time<Tstart)=[]; %remove the points outside the time crop region
        Time    = Time(Ind); %cropped time vector
        Contour = Contour(Ind); %cropped contour vector
        Force   = Force(Ind); %cropped force vector
        %% We break up the trace into VelWinLength fragments and calculate the velocity on each of those fragments
        FinishL = Contour(end); %we start at the very end of the trace since we care most about the stuff at the end
        StartL  = FinishL+VelWinLength; %we define the window with StartL:FinishL
        while StartL < Contour(1) %as long as we're staying within the cropped part of the trace
            Ind=1:length(Contour); %complete index of the cropped contour vector
            KeepFromBelow=Contour>FinishL;
            KeepFromAbove=Contour<StartL;
            Keep = KeepFromAbove.*KeepFromBelow;
            Remove = ~Keep;
            
            Ind(Remove)=[];
            
            if ~isempty(Ind)
                %calculate the velocity with a simple division, I tried doing a
                %linear fit but there's not much of a difference between the two
                if length(Ind)>1
                    Vel.Velocity(end+1) = (Contour(Ind(1))-Contour(Ind(end)))/(Time(Ind(1))-Time(Ind(end)));
                    Vel.Location(end+1) = mean(Contour(Ind)); %location where velocity was measured
                    Vel.Force(end+1)    = mean(Force(Ind)); %force where velocity was measured
                    Vel.Segment(end+1)  = abs((Contour(Ind(1))-Contour(Ind(end)))); %we need a positive value here
                end
            end
            %define the new Start:Finish limits for the next calculation
            FinishL  = StartL; %what used to be the start is now the finish
            StartL   = FinishL+VelWinLength; %adjust the start accordingly
        end
  
        %% Save the Velocity Data in a separate file in a separate folder
        Folder = [analysisPath '\' 'VelocityData'];
        if ~exist(Folder,'dir') %if this folder doesn't exist, create it
            mkdir(Folder); %create it
        end        
        
        FileMAT = [Folder '\' File{i}(1:end-4) '_velocity.mat'];
        %save (FileMAT, 'Trace','FiltTrace','Vel','Parameters'); %save data to MAT file
        save (FileMAT, 'Vel','Parameters'); %save data to MAT file
        disp(['Saved file ' FileMAT ]); %show message in terminal
        
        %% Plot the Velocity Histogram for the entire trace
        if strcmp(PlotOption,'plot')
            HistBins=HistLowerLim:HistBinWidth:HistUpperLim;
            figure; hist(Vel.Velocity,HistBins);
            set(gca,'XLim',[HistLowerLim HistUpperLim]);
            set(gca,'YLimMode','auto');
            title(File{i});
            % Plot Velocity versus Location
            figure; plot(Vel.Location, Vel.Velocity,'.b');
            xlabel('Location (bp)'); ylabel('Velocity (bp/sec)');
            title(File{i});
        end
    else
        %the Crop *.crop file doesn't exist, skip the corresponding *.pro file
        disp([File{i} ' was skipped because it has no crop (*.crop) file']);
    end %end of IF
end %end of FOR