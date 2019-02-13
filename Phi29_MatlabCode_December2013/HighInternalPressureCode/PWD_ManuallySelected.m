function PWD_ManuallySelected()
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
Default = {'2500','100','0.5'};
Options.Resize      = 'on'; 
Options.WindowStyle = 'normal'; 
Options.Interpreter = 'tex';

global BinPWD;
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth = str2num(Answer{1});
Filter    = str2num(Answer{2});
BinPWD    = str2num(Answer{3});

FiltFact  = round(Bandwidth/Filter); %Filtering Factor

Phage=LoadPhage(); %the location of the file is stored in analysisPath
%clear stepdata;

%% Select the portion of the data that you want analyzed
Length = [];
Time   = [];
Figure1 = figure; set(Figure1,'Position',[9 49 667 642]);
hold on;
for i=1:length(Phage.contour)
    Length = [Length Phage.contour{i}];
    Time   = [Time   Phage.time{i}];
    plot(FilterAndDecimate(Phage.time{i}, FiltFact),FilterAndDecimate(Phage.contour{i}, FiltFact),'b');
end

global FilteredLength FilteredTime;
%use boxcar for a smooth PWD
FilteredLength = BoxcarFilter(Length, FiltFact); %filter the data
FilteredTime   = BoxcarFilter(Time,   FiltFact); %filter the data
%PlotPhagesDecimate(Phage,FiltFact);

hold off;
xlabel('Time (sec)');
ylabel('Tether Length (bp)');
legend(['File: ' Phage.file ]);
PWD_SelectionGUI();
%set(gca,'Ylim',[-1000 21000]); %set the vertical axis limit    

%where the PWD window starts and ends
%in our case the PWD window is simply the current feedback cycle

%now calculate the PWD for this window
%define the bins for the data, later used to calculate the PWD
    % HistogramBins = min(TempL):HistBinWidth:max(TempL);
    % [N, D] = GhePairWiseDistribution(TempL,HistogramBins);
%PWD.Number{fc}  = N;
%PWD.Distance{fc}= D; 