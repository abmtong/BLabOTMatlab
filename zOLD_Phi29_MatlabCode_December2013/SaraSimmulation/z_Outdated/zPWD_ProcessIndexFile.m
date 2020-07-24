function PWD = PWD_ProcessIndexFile()
% This function loads an index file that was used to calculate step-sizes
% and calculated the Pairwise Distribution Probability for the selected
% Phages and Feedback Cycles. This will help understand the step size
% distribution and whatnot.
%
% USE: PWD_ProcessIndexFile()
%
% Gheorghe Chistol, 18 Nov 2010


% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)',...
          'Filter Frequency (Hz)', ...
          'Histogram Bin Width (bp)',...
          'PWD Window Size (bp)'};
Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'2500','50','0.5','50'};
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

% Load the Index File
IndexFile = uigetfile([ [analysisPath '\'] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
IndexFileName = IndexFile;
IndexFile = [analysisPath '\' IndexFile];
if ~exist(IndexFile,'file') %if no files were selected or file doesn't exist
    disp('No Index File phage files were selected'); return;
end

SaveFile       = [];
[SelectedPhages SelectedFeedbackCycles] = LoadPhageList(IndexFile); %loads the index of the sub-traces that are good
%SelectedPhages{p} cell structure
%SelectedFeedbackCycles{fc} cell structure

for p=1:length(SelectedPhages)
    %set the correct parameters first
    PhageFolder            = analysisPath;
    PhageFile              = ['phage' SelectedPhages{p} '.mat'];
    PhageFeedbackCycleList = SelectedFeedbackCycles{p};
    
    %calculate the pairwise distribution
    PWD(p) = PWD_CalculateForSingleFeedbackCycle(PhageFolder,PhageFile,PhageFeedbackCycleList,HistBinWidth,Filter);
end

SaveFolder = [analysisPath '\' 'PWD_Results'];
if ~isdir(SaveFolder);
    mkdir(SaveFolder);%create the directory
end

SaveFile = [IndexFileName(1:end-4) '_PWD_Results.mat'];
SaveFile = [SaveFolder '\' SaveFile];
save(SaveFile,'PWD');
disp(['Saved stepping data to ' SaveFile]);

