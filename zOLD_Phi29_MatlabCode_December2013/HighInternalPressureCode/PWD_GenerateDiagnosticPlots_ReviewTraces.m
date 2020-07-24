function PWD_GenerateDiagnosticPlots_ReviewTraces()
% This is a companion function to PWD_GenerateDiagnosticPlots.m
% It simply loads an index file for StepFinding and plots all the feedback
% Cycles. You can review them before running the StepFinding Algorythm
%
% USE: PWD_GenerateDiagnosticPlots_ReviewTraces
%
% Gheorghe Chistol, 27 Nov 2010


% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)',...
          'Filter Frequency (Hz)'};
Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'2500','100'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth     = str2num(Answer{1});
F             = str2num(Answer{2}); %this is the desired filter frequency
Filter        = round(Bandwidth/F); %filtering factor

AddMainCodePath; %make the rest of the function available
global analysisPath; %set the analysis path if neccessary
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.');
    return;
end

%% Load the Index File
IndexFile = uigetfile([ [analysisPath '\'] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
IndexFile = [analysisPath '\' IndexFile];
if ~exist(IndexFile) %if no files were selected or file doesn't exist
    disp('No Index File phage files were selected'); return;
end

[SelectedPhages SelectedFeedbackCycles] = LoadPhageList(IndexFile); %loads the index of the sub-traces that are good


for p=1:length(SelectedPhages) %p is the phage index
    CurrentPhageFileName = [analysisPath '\' 'phage' SelectedPhages{p} '.mat'];
    if ~exist(CurrentPhageFileName,'file') %if the phage data file does not exist
        disp(['!!! Phage Data File does not exist: ' CurrentPhageFileName]);
    else %proceed to analyzing the data
        load(CurrentPhageFileName);
        phage=stepdata; clear stepdata;%indexed data fromt the current trace
        StartT=tic; %start the timer to measure the duration of calculation

        for i=1:length(SelectedFeedbackCycles{p}); %fc is the index of feedback cycles
            fc=SelectedFeedbackCycles{p}(i); %current feedback cycle
            %SelectedPhages(p)
            %fc
            T = FilterAndDecimate(phage.time{fc},Filter); %#ok<*AGROW>
            L = FilterAndDecimate(phage.contour{fc},Filter);

            h=figure;
            plot(T,L,'-b'); hold on;
            ylabel('Tether Length (bp)');
            xlabel('Time(sec)');
            title([phage.file(1:end-4) ', Feedback Cycle: ' num2str(fc) ]);

            ImgFolder = [analysisPath '\' 'PWD_DiagnosticPlots_ReviewTraces\' phage.file(1:end-4)];
            if ~isdir(ImgFolder);
                mkdir(ImgFolder);%create the directory
            end
            saveas(h, [ImgFolder '\' phage.file(1:end-4) '_' num2str(fc)], 'png');
            close(h);
        end
        ElapsedT=toc(StartT);
        disp(['It took ' num2str(ElapsedT) ' sec to generate PWD Diagnostic Plots for ' phage.file(1:end-4)]);
    end
end