function PWD_GenerateDiagnosticPlots()
% This function loads a phage trace, calculates the PWD for each feedback
% cycle, plots and saves the PWD for each of these feedback cycles. Then
% you can go through the saved plot images and pick the ones with good
% signal for further step-finding analysis. The PWD diagnostic plots are
% saved in ./PWD_DiagnosticPlots
%
% USE: PWD_GenerateDiagnosticPlots()
%
% Gheorghe Chistol, 24 Nov 2010


% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)',...
          'Filter Frequency (Hz)', ...
          'Histogram Bin Width (bp)'};
Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'2500','250','.5'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth     = str2num(Answer{1});
F             = str2num(Answer{2}); %this is the desired filter frequency
HistBinWidth  = str2num(Answer{3});
%WindowSize    = str2num(Answer{4}); %this is the size of the window which is used to calculate the PWD
Filter        = round(Bandwidth/F); %filtering factor

AddMainCodePath; %make the rest of the function available
global analysisPath; %set the analysis path if neccessary
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.');
    return;
end

File = uigetfile([ [analysisPath '\'] 'phage*.mat'], 'Please Selecte Phage Traces for PWD Diagnostics:','MultiSelect', 'on');
if isempty(File) %if no files were selected
    disp('No *.mat phage files were selected');
    return;
end

if ~iscell(File) %if there is only one file, make it into a cell, for easier processing later
    temp=File; clear File; File{1}=temp;
end
    
for p=1:length(File) %p is the phage index
    StartT=tic; %start the timer to measure the duration of calculation
    load([analysisPath '\' File{p}]);
    phage=stepdata; clear stepdata;
    disp(['Calculating PWD for ' phage.file]);

    for fc=1:length(phage.contour); %fc is the index of feedback cycles
        T = FilterAndDecimate(phage.time{fc},Filter); %#ok<*AGROW>
        L = FilterAndDecimate(phage.contour{fc},Filter);

        if range(T)>1 %only look at the feedback traces longer than 1 sec
            %where the PWD window starts and ends
            PWD.Start(fc)  = L(1);
            PWD.Finish(fc) = L(end);
            %now calculate the PWD for this window
            %define the bins for the data, later used to calculate the PWD
            HistogramBins = min(L):HistBinWidth:max(L);

            [N, D] = GhePairWiseDistribution(L,HistogramBins);
            N = N/sum(N); %normalize

            %calculate std/mean as a measure of "wiggliness"
            IndLarger = D>10; %find everything larger than 10
            LimitedN = N(IndLarger);
            Score = std(LimitedN);

            h=figure;
            plot(D,N,'-b'); hold on;
            YLim=get(gca,'YLim');
            YLim(1)=0;
            plot([10 10],YLim,':','Color',[.5 .5 .5]);
            plot([20 20],YLim,':','Color',[.5 .5 .5]);
            plot([30 30],YLim,':','Color',[.5 .5 .5]);
            plot([40 40],YLim,':','Color',[.5 .5 .5]);
            plot([50 50],YLim,':','Color',[.5 .5 .5]);
            %plot([60 60],YLim,':','Color',[.5 .5 .5]);
            %plot([70 70],YLim,':','Color',[.5 .5 .5]);
            %plot([80 80],YLim,':','Color',[.5 .5 .5]);
            %plot([90 90],YLim,':','Color',[.5 .5 .5]);
            set(gca,'XLim',[0 80]); %for consistency and ease of review
            xlabel('Distance (bp)');
            ylabel('Normalized PWD');
            title([' Filling: ' num2str(21-mean(L)/1000,4) 'kb, Trace: ' phage.file(1:end-4) ', Feedback Cycle: ' num2str(fc) ]);
            %to get the PWD, plot Number versus Distance

            ImgFolder = [analysisPath '\' 'PWD_DiagnosticPlots\' phage.file(1:end-4)];
            if ~isdir(ImgFolder);
                mkdir(ImgFolder);%create the directory
            end
            saveas(h, [ImgFolder '\' phage.file(1:end-4) '_' num2str(fc)], 'png');
            close(h);
        else
            disp(['Feedback Trace #' num2str(fc) ' of ' phage.file(1:end-4) ' was skipped due to insufficient data.']);
    %        RemoveInd = [RemoveInd fc]; %this feedback trace was discarded, remove it at the end
        end   
    end
    ElapsedT=toc(StartT);
    disp(['It took ' num2str(ElapsedT) ' sec to generate PWD Diagnostic Plots for ' phage.file(1:end-4)]);
end