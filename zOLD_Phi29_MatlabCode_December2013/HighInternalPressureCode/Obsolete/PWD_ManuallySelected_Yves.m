function PWD_ManuallySelected_Yves()
% This is a function that allows you to load a phage trace, plot it, then
% make a selection along the trace and generate the PWD for the selected
% data. This is to be used as an exploratory tool - a quick and dirty way
% of inspecting your data using the PWD.
%
% PWD_ManuallySelected()
%
% Gheorghe Chistol, 23 Nov 2010

AddMainCodePath; %add the old code folder to the path

Prompt  = {'Acquisition Bandwidth (Hz)','Filter Frequency (Hz)','PWD Bin Width (bp)'};
Title   = 'Enter the Following Parameters';
Lines   = 1; 
Default = {'2500','10','0.02'}; %0.02 nm binning for pairwise distribution
Options.Resize      = 'on'; 
Options.WindowStyle = 'normal'; 
Options.Interpreter = 'tex';

global BinPWD;
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth = str2num(Answer{1});
Filter    = str2num(Answer{2});
BinPWD    = str2num(Answer{3});

FiltFact  = round(Bandwidth/Filter); %Filtering Factor

%% Load the file that contains the Force Extension data with single-basepair
%resolution level
global analysisPath;
if isempty(analysisPath)
    disp('Please Define Analysis Path using SetAnalysisPath');
    return;
end

[file, currentpath] = uigetfile([analysisPath '/' 'ForceExtension*.mat'], 'MultiSelect', 'off');
load([currentpath file]);
%now in the workspace you have three structure: CalibratedData,
%ContourData, Offset Data, focuson Contour Data

%% Select the portion of the data that you want analyzed
Figure1 = figure; set(Figure1,'Position',[9 49 667 642]);
hold on;
Length = ContourData.extension;
Time   = ContourData.time;

global FilteredLength FilteredTime;
FilteredLength = FilterAndDecimate(Length, FiltFact); %filter the data
FilteredTime   = FilterAndDecimate(Time,   FiltFact); %filter the data

plot(FilteredTime, FilteredLength,'b');
hold off;

xlabel('Time (sec)');
ylabel('Tether Extension (nm)');
legend(['File: ' file ]);
PWD_SelectionGUI_Yves();


%where the PWD window starts and ends
%in our case the PWD window is simply the current feedback cycle

%now calculate the PWD for this window
%define the bins for the data, later used to calculate the PWD
    % HistogramBins = min(TempL):HistBinWidth:max(TempL);
    % [N, D] = GhePairWiseDistribution(TempL,HistogramBins);
%PWD.Number{fc}  = N;
%PWD.Distance{fc}= D; 