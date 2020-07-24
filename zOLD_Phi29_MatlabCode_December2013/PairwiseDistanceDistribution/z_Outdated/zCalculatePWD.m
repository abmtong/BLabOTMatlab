function PWD = CalculatePWD()
% This function calculates the pairwise distance distribution for the
% entire trace within the crop section specified by the "*.crop" file. 
% You can select multiple files at once (even the ones without corresponding 
% "*.crop" definitions. Only the phages with "*.crop" will be processed, 
% the rest will be skipped.
%
% You have to specify the following parameters: 
% Data Acquisition Bandwidth   (2500Hz by default)
% Filtering Frequency          (50-200 Hz depending on the translocation speed)
% Histogram Bin Width          (PWD data will be binned, 0.2-0.5bp is good here)
% PWD Window Size              (maximum separation of data used to calculate PWD)
%
% The function
% saves the results of the calculation in the PWDData folder in the
% AnalysisFolder. Note that the function outputs the PWD data structure for
% the last processed trace only (in case you process multiple files at
% once)
%
% How to read the PWD results data structure:
% PWD is calculated in windows. Each window is defined by the DNA contour 
% length at the "Start" and "Finish" of the window.
%
% The actual PWD results are contained in the "Number" and "Distance" fields
% plot(PWD.Distance{i},PWD.Number{i}) will plot the PWD graph you expect
%
% "Segment" is the length of the actual window used to calculate the PWD
% (very close to the specified value)
%
% "Location" specifies the position of the portion of DNA used to calculate PWD
% in this particular window (middle of the piece, used for sorting PWD results 
% as a function of capsid filling)
%
% "Time" and "Contour" refer to the (filtered) DNA contour length as a function of
% time for this particular window of data.
%
% "Tstart" and "Tstop" are the crop marks from the "*.crop" file
%
% "FilterFreq" is the bandwidth to which the data was filtered prior to PWD analysis
%
% Example of PWD Data Structure Contents:
%     Finish: [1x24 single]
%      Start: [1x24 single]
%     Number: {1x24 cell}
%   Distance: {1x24 cell}
%    Segment: [1x24 single]
%   Location: [1x24 single]
%       Time: {1x24 cell}
%    Contour: {1x24 cell}
% FilterFreq: 50
%     Tstart: 85.7143
%      Tstop: 697.6959
%
% USE: PWD = CalculatePWD()
%
% Gheorghe Chistol 27 Oct 2010


%% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)',...
          'Filtered Frequency (Hz)', ...
          'Histogram Bin Width (bp)',...
          'PWD Window Size (bp)'};
Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'2500','50','0.5','200'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth     = str2num(Answer{1});
F             = str2num(Answer{2}); %this is the desired filter frequency
HistBinWidth  = str2num(Answer{3});
WindowSize    = str2num(Answer{4}); %this is the size of the window which is used to calculate the PWD
Filter        = round(Bandwidth/F); %filtering factor

global analysisPath; %set the analysis path if neccessary
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.');
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
% 1.Filter the data and merge it in a single vector
% 2.Split the data vector into several windows
% 3.Calculate the PWD within each of those windows
for f=1:length(File)
    CropFile = [analysisPath '\CropFiles\' File{f}(6:end-4) '.crop']; % this is the complete address of the crop file that should 
                                                                      % correspond to the current phage *.mat file
    if exist(CropFile,'file') %check if the crop file exists, if it doesn't, don't process the phage file at all
        disp('--------------------');        
        disp([File{f} ' is being processed now']);
        StartT=tic;
        load([analysisPath '\' File{f}]); %load a single specified phage file
        Trace = stepdata; clear stepdata; %load the data and clear intermediate data
        FID   = fopen(CropFile); %open the *.crop file
        Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
        Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
        TimeLimits=[Tstart Tstop];
        Index=[]; %index of the feedback cycles that we're interested in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        T=[]; %the filtered Time vector
        L=[]; %the filtered Contour Length Vector
        for t=1:length(Trace.time);
            T = [T FilterAndDecimate(Trace.time{t},    Filter)]; %#ok<*AGROW>
            L = [L (FilterAndDecimate(Trace.contour{t}, Filter))];
            %[a b]=size(L); 
            %if a>b 
            %    L=L'; %transpose for convenience
            %end

            %clear the data that is outside the selected time range
            temp=(T<Tstart)+(T>Tstop);
            RemoveIndex=find(temp==1);
            T(RemoveIndex)=[];
            L(RemoveIndex)=[];
        end
        
        %now divide the data into several windows
        w=1; %window index
        PWD.Finish(w)=L(end); %start at the very end of the dataset
        FinishInd = length(L);
        while L(1)>PWD.Finish(end)+WindowSize
            PWD.Start(w) = PWD.Finish(w)+WindowSize;
            temp = abs(L-PWD.Start(w));
            StartInd  = find(temp == min(temp)); StartInd=StartInd(1);
            PWD.Start(w) = L(StartInd);
            %the data for this window is contained in L(StartInd:FinishInd);
            %now calculate the PWD for this window
            %define the bins for the data, later used to calculate the PWD
            TempL = L(StartInd:FinishInd); %the contour length data for this window
            TempT = T(StartInd:FinishInd); %the time data for this window
            HistogramBins = min(TempL):HistBinWidth:max(TempL);
            
            [N, D] = GhePairWiseDistribution(TempL,HistogramBins);
            PWD.Number{w}  = N;
            PWD.Distance{w}= D; 
            %to get the PWD, plot Number versus Distance

            PWD.Segment(w) = abs(PWD.Start(w)-PWD.Finish(w)); %the length of the packaged DNA segment
            PWD.Location(w)= mean(TempL); %where along DNA where this feedback cycle is located
            PWD.Time{w}    = TempT;
            PWD.Contour{w} = TempL;
            PWD.FilterFreq = F;
            PWD.Tstart     = Tstart;
            PWD.Tstop      = Tstop;

            %try initiating the next window
            w=w+1;
            FinishInd = StartInd-1;
            PWD.Finish(w)=L(FinishInd); %the next window stops right where the current window starts
        end
        PWD.Finish(end)=[]; %remove the last entry since it's useless

        %figure;
        %plot(PWD.Distance{i},PWD.Number{i});
        %xlabel('Pairwise Distance (bp)');
        %ylabel('Occurence Number');
        %title(['File: ' File{f} '; Cell Used: ' num2str(Index(i)) ]);
        
        %% Save the Velocity Data in a separate file in a separate folder
        Folder = [analysisPath '\' 'PWDData'];
        if ~exist(Folder,'dir') %if this folder doesn't exist, create it
            mkdir(Folder); %create it
        end        
        
        FilePWD = [Folder '\' File{f}(1:end-4) '_pwd.mat'];
        save (FilePWD, 'PWD'); %save data to a file
        disp(['Saved file ' FilePWD ]); %show message in terminal
        ElapsedT=toc(StartT);
        disp(['It took ' num2str(ElapsedT) ' sec to perform the PWD calculation']);
        disp(['Data Saved to ' FilePWD]);
    else
        %the Crop *.crop file doesn't exist, skip the corresponding *.pro file
        disp([File{f} ' was skipped because it has no crop (*.crop) file']);
    end %end of IF
end %end of FOR