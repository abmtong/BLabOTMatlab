% function HIP_CalculateVelocities()
% This function requires *.mat and the corresponding *.crop files. It
% calculates the velocity single or multiple phage traces at once. It was
% written to investigate whether ATP binding is affected in the late stages
% of packaging. All data is saved in the AnalysisFolder
% It requires the following parameters:
% Filtered Frequency (Hz):  data is filtered down to this freq to reduce noise
% Hist Lower Limit:         lower limit of the histogram, for consistent plotting
% Hist Upper Limit:         upper limit of the histogram, for consistent plotting
% Hist Bin Width:           width of the histogram bins, for consistent plotting
% USE: HIP_CalculateVelocities()
%
% Gheorghe Chistol, 21 Jun 2010
% edited            16 Aug 2010

PlotOption='none';
global analysisPath;
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.');
    return;
end
%% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)','Filtered Frequency (Hz)','Velocity Window Length (bp)', 'Hist Lower Limit (bp/sec)','Hist Upper Lim (bp/sec)','Hist Bin Width'};
Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'2500','100','40','-100','200','10'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth     = str2num(Answer{1});
F             = str2num(Answer{2}); %this is the desired filter frequency
VelWinLength  = str2num(Answer{3}); %the # of bp used to calculate one velocity point
HistLowerLim  = str2num(Answer{4});
HistUpperLim  = str2num(Answer{5});
HistBinWidth  = str2num(Answer{6});

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
        Time    = []; %unified time - one vector for the entire trace
        for n=1:length(Trace.time)
            FiltTrace.Time{n} = FilterAndDecimate(Trace.time{n}, N); %filter the time and the other important values
            FiltTrace.Contour{n} = FilterAndDecimate(Trace.contour{n}, N);
            FiltTrace.Force{n} = FilterAndDecimate(Trace.force{n}, N);
            Contour = [Contour FiltTrace.Contour{n}']; %#ok<*AGROW>
            Time    = [Time    FiltTrace.Time{n}];
        end
        TimeLimits=[Tstart Tstop];
        figure;
        subplot(2,1,1); hold on;
        for n=1:length(FiltTrace.Time)
            plot(FiltTrace.Time{n}, FiltTrace.Contour{n},'b');
        end
        ylabel('Contour Lenth (bp)');
        title([FiltTrace.File]);
        set(gca,'XLim',TimeLimits); set(gca,'YLimMode','auto');
        
        subplot(2,1,2); hold on;
        for n=1:length(FiltTrace.Time)
            plot(FiltTrace.Time{n}, FiltTrace.Force{n},'b');
        end
        ylabel('Force (pN)');
        xlabel('Time (sec)');
        set(gca,'XLim',TimeLimits); set(gca,'YLimMode','auto');
        
        %% Go through each subtrace and break ip up into smaller fragments.
        %Fit a straight line through those fragments and save the vel data
        Velocity = []; %velocity for the i-th file
        Location = []; %location where velocity was measured
        
        IndSmaller = Time < Tstop; %find the index of all timepoints smaller than Tstop
        IndLarger  = Time > Tstart; %find the index of all timepoints larger than Tstart
        Ind = IndSmaller.*IndLarger; %overall index, t>Tstart && t<Tstop
        CropInd = find(Ind==1); %these are the points we're interested in
        Time    = Time(CropInd); %cropped time vector
        Contour = Contour(CropInd); %cropped contour vector
        
        %% We break up the trace into VelWinLength fragments and calculate the velocity on each of those fragments
        K = floor(abs(Contour(1)-Contour(end))/VelWinLength); %how many full velocity windows we can get
        figure; hold on;
        for k=1:K
            %the current velocity calculation window starts @ StartL and ends @ FinishL
            StartL  = Contour(end)+(k-1)*VelWinLength;
            FinishL = StartL+VelWinLength; 
            WinIndSmaller = Contour > StartL;
            WinIndLarger  = Contour < FinishL;
            WinInd        = WinIndSmaller.*WinIndLarger;
            SelectInd     = find(WinInd==1); %these are the points we're interested in
            x = Time(SelectInd); %transpose it so it's also a column
            y = Contour(SelectInd);
            p = polyfit(x,y,1); %do a linear fit
            Y = polyval(p,x); %fitted line
            plot(x,y,'.k');
            plot(x,Y,'-b');
            %return
            Velocity(end+1)= p(1); %add this to the velocity data
            Location(end+1)= mean(y); %location where velocity was measured
        end
  
        FileMAT = [analysisPath '\' File{i}(1:end-4) '_HIP_velocity.mat'];
        save (FileMAT, 'Trace','FiltTrace','Velocity','Location','Time'); %save data to MAT file
        disp(['Saved file ' FileMAT ]); %show message in terminal
        figure; hist(Velocity,100);
    else
        %the Crop *.crop file doesn't exist, skip the corresponding *.pro file
        disp([File{i} ' was skipped because it has no crop (*.crop) file']);
    end %end of IF
end %end of FOR