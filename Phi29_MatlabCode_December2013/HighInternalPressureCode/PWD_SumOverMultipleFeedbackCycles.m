function [PWD TotalN TotalD]=PWD_SumOverMultipleFeedbackCycles()
% This function loads an index file (the same as the one used for step
% finding) and sums over all the specified traces to generate an aggregate
% PWD plot, therefore taking care of averaging PWDs in an automated
% fashion.
%
% PWD(n+1).N=N;
% PWD(n+1).D=D;
% PWD(n+1).Phage = SelectedPhages{p};
% PWD(n+1).FeedbackCycle = fc;
% PWD(n+1).PhageFile = PhageFile; %the complete address of the *mat file
% PWD(n+1).FilterBand = F; %the bandwidth of data after filtering
%
% USE: PWD_SumOverMultipleFeedbackCycles()
%
% Gheorghe Chistol, 10 Feb 2011

% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)',...
          'Filter Frequency (Hz)', ...
          'PWD Histogram Bin Width (bp)', ...
          'PWD Distance Range (bp)'};
Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'2500','100','.25','50'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth     = str2num(Answer{1});
F             = str2num(Answer{2}); %this is the desired filter frequency
HistBinWidth  = str2num(Answer{3});
MinDistRange  = str2num(Answer{4}); %this sets the shortest distance range for the PWD plot which is acceptable
                                    %any PWD spectrum that covers a distance shorter than this will be ignored    
Filter        = round(Bandwidth/F); %filtering factor

AddMainCodePath; %make the rest of the function available
global analysisPath; %set the analysis path if neccessary
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.'); return;
end

%% Select the Index File that lists the Feedback Cycles of interest
[IndexFile IndexFilePath]= uigetfile([ [analysisPath filesep] '*.txt'], 'Select the IndexFile for PWD Averaging/Aggregation:','MultiSelect', 'off');
if isempty(IndexFile) %if no files were selected
    disp('No IndexFile was selected'); return;
end
   
PWDSaveFile = [IndexFilePath filesep IndexFile(1:end-4) '_AveragedPWD.mat'];
[SelectedPhages SelectedFeedbackCycles] = LoadPhageList([IndexFilePath filesep IndexFile]); %loads the index of the sub-traces that are good
PWD=[]; %this is the data structure that will store all the aggregated PWD data

for p=1:length(SelectedPhages) %p is the phage index
    PhageFile = [analysisPath filesep 'phage' SelectedPhages{p} '.mat']; %the complete address of the Phage Trace File
    if exist(PhageFile,'file') %this trace exists, proceed to generate PWD
        load(PhageFile); %load the trace
        phage=stepdata; clear stepdata;
        disp(['Generating PWD plots for ' SelectedPhages{p}]);
        for fc_index=1:length(SelectedFeedbackCycles{p}) %index fc stands for "FeedbackCycle"
            %disp(['Generating PWD plots for ' SelectedPhages{p} ' Feedback Cycle #' num2str(SelectedFeedbackCycles{p}(fc_index))]);
            fc = SelectedFeedbackCycles{p}(fc_index); %currend feedback cycle number
            
            a = 1;
            b = ones(1,Filter)/Filter;
            T = filter(b,a,phage.time{fc}); %boxcar Filter
            L = filter(b,a,phage.contour{fc}); %boxcar Filter
            %T  = FilterAndDecimate(phage.time{fc},Filter); %#ok<*AGROW>
            %L  = FilterAndDecimate(phage.contour{fc},Filter);

            if range(T)>1 %only look at the feedback traces longer than 1 sec
                %define the bins for the data, later used to calculate the PWD
                HistogramBins = min(L):HistBinWidth:max(L);
                [N, D] = GhePairWiseDistribution(L,HistogramBins);
                n=length(PWD);
                PWD(n+1).N=N;
                PWD(n+1).D=D;
                PWD(n+1).Phage = SelectedPhages{p};
                PWD(n+1).FeedbackCycle = fc;
                PWD(n+1).PhageFile = PhageFile; %the complete address of the *mat file
                PWD(n+1).FilterBand = F; %the bandwidth of data after filtering
            else
                disp(['Feedback Trace #' num2str(fc) ' of phage' SelectedPhages{p} ' was skipped due to insufficient data.']);
            end
        end
    end
end

AggregateN=[]; %this is a matrix, different feedback cycles are listed in individual rows
AggregateD=[]; %this is a single array
if ~isempty(PWD) %if we have some data, go through it and organize further
    for i=1:length(PWD)
        Ind=find(PWD(i).D>MinDistRange,1); %find the first item that is larger than MinDistRange
        if ~isempty(Ind) 
            %if the current PWD covers enough Distance range, use it
            if isempty(AggregateN)
                %this is the very first PWD
                AggregateN = PWD(i).N(1:Ind);
                AggregateD = PWD(i).D(1:Ind);
            else
                [Nrows Ncolumns]=size(AggregateN);
                AggregateN(end+1,:)=PWD(i).N(1:Ncolumns); %#ok<AGROW>
                %AggregateD stays the same;
            end
        end
    end
else
    disp('No PWD data was accumulated');
end

%normalize the AggregateN
[r c]=size(AggregateN);
for i=1:r
	AggregateN(i,:)=AggregateN(i,:)./sum(AggregateN(i,:));
end
%% Now add the PWD and plot results
TotalN=sum(AggregateN(:,:)); %sum over each individual column and then normalize
TotalN=TotalN/sum(TotalN);
TotalD=AggregateD;
figure;
plot(TotalD,TotalN,'-b','LineWidth',2);
%plot(AggregateD,AggregateN,'-b');
xlabel('Distance (bp)');
ylabel('Averaged PWD (arbitrary)');
title([IndexFile],'Interpreter','none');
%set(gca,'XLim',[0 50]);
saveas(gcf,[IndexFilePath filesep IndexFile(1:end-4) '_PlotPWD'],'fig'); %save the Figure
pause(1); %wait for a second then close the figure
close(gcf);
%save(PWDSaveFile,'AggregateD','AggregateN','PWD','TotalN','TotalD');