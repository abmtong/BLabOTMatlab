function [PWD Pairwise]=Pwd_SumOverMultipleFeedbackCycles_FillingTitration()
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
% USE: [PWD Pairwise]=Pwd_SumOverMultipleFeedbackCycles_FillingTitration()
%
% Gheorghe Chistol, 30 May 2012

% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)',...
          'Filter Frequency (Hz)', ...
          'PWD Histogram Bin Width (bp)', ...
          'PWD Distance Range (bp)',...
          'DNA Tether Length (bp)',...
          'Filling Partition'};
Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'2500','100','.1','50','21042','See Code'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth     = str2num(Answer{1});
F             = str2num(Answer{2}); %this is the desired filter frequency
HistBinWidth  = str2num(Answer{3});
MinDistRange  = str2num(Answer{4}); %this sets the shortest distance range for the PWD plot which is acceptable
                                    %any PWD spectrum that covers a distance shorter than this will be ignored    
Filter        = round(Bandwidth/F); %filtering factor
TetherLength  = str2num(Answer{5}); %in bp    
GenomeLength  = 19282; %in bp
FillingMarks  = [60 80 85 90 95 100 110];

global analysisPath; %set the analysis path if neccessary

%% Select the Index File that lists the Feedback Cycles of interest
[IndexFile IndexFilePath]= uigetfile([ [analysisPath filesep] '*.txt'], 'Select the IndexFile for PWD Averaging/Aggregation:','MultiSelect', 'off');
if isempty(IndexFile) %if no files were selected
    disp('No IndexFile was selected'); return;
end
   
PWDSaveFile = [IndexFilePath filesep IndexFile(1:end-4) '_AveragedPWD.mat'];
[SelectedPhages SelectedFeedbackCycles] = Pwd_LoadPhageList([IndexFilePath filesep IndexFile]); %loads the index of the sub-traces that are good
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
            
           
            
            if range(phage.time{fc})>.5 %only look at the feedback traces longer than .5 sec
                T = Pwd_BoxcarFilter(phage.time{fc},    Filter);
                L = Pwd_BoxcarFilter(phage.contour{fc}, Filter);
                %define the bins for the data, later used to calculate the PWD
                HistogramBins = min(L):HistBinWidth:max(L);
                [N, D] = Pwd_ComputePairwiseDistanceDistribution(L,HistogramBins);
                n=length(PWD);
                PWD(n+1).N=N;
                PWD(n+1).D=D;
                PWD(n+1).Phage = SelectedPhages{p};
                PWD(n+1).FeedbackCycle = fc;
                PWD(n+1).PhageFile = PhageFile; %the complete address of the *mat file
                PWD(n+1).FilterBand = F; %the bandwidth of data after filtering
                PWD(n+1).TetherLengthStart  = L(1);
                PWD(n+1).TetherLengthFinish = L(end);
                PWD(n+1).LengthPackaged     = range(L);
                PWD(n+1).Location           = mean(L);
                PWD(n+1).Filling            = 100*(TetherLength-PWD(n+1).Location)/GenomeLength; %in percent
            else
                disp(['Feedback Trace #' num2str(fc) ' of phage' SelectedPhages{p} ' was skipped due to insufficient data.']);
            end
        end
    end
end
figure; hold on;
for f=1:length(FillingMarks)-1
    Pairwise.N{f}     = [];
    Pairwise.D{f}     = [];
    Pairwise.Count{f}  = 0; %how many feedback cycles went into this calculation
    Pairwise.Length{f} = 0; %in basepairs, how much DNA was translocated
    
    if ~isempty(PWD) %if we have some data, go through it and organize further
        for i=1:length(PWD)
            Ind=find(PWD(i).D>MinDistRange,1); %find the first item that is larger than MinDistRange
            if ~isempty(Ind) && PWD(i).Filling>FillingMarks(f) && PWD(i).Filling <= FillingMarks(f+1)
                %if the current PWD covers enough Distance range, 
                %and if it has the right filling, use it
                if isempty(Pairwise.N{f})
                    %this is the very first PWD
                    Pairwise.N{f} = PWD(i).N(1:Ind);
                    Pairwise.D{f} = PWD(i).D(1:Ind);    
                    Pairwise.Count{f}  = Pairwise.Count{f}+1;
                    Pairwise.Length{f} = Pairwise.Length{f}+PWD(i).LengthPackaged;
                else
                    if length(Pairwise.N{f})==length(PWD(i).N(1:Ind))
                        Pairwise.N{f} = Pairwise.N{f}+PWD(i).N(1:Ind);
                        Pairwise.Count{f}  = Pairwise.Count{f}+1;
                        Pairwise.Length{f} = Pairwise.Length{f}+PWD(i).LengthPackaged;
                    end
                end
                
            end
        end
    else
        disp('No PWD data was accumulated');
    end

    %normalize the AggregateN
    Pairwise.N{f}=Pairwise.N{f}/sum(Pairwise.N{f});
    figure;
    plot(Pairwise.D{f},Pairwise.N{f}+(f-1)*1e-3,'-b','LineWidth',2);
    xlabel('Distance (bp)');
    ylabel('Averaged PWD (arbitrary)');
    title(['Filling' num2str(FillingMarks(f)) '-' num2str(FillingMarks(f+1)) '%; Total DNA = ' num2str(round(Pairwise.Length{f})) ' bp'],'Interpreter','none');
    set(gca,'XLim',[0 50]);
%    saveas(gcf,[IndexFilePath filesep IndexFile(1:end-4) '_PlotPWD'],'fig'); %save the Figure
    
% %% find a local minimum between 5 and 15 bp
    D = Pairwise.D{f};
    N = Pairwise.N{f};
    
    [LocalMaxInd LocalMinInd] = Pwd_IdentifyLocalMaxima(D, N, 1.01);
    D = Pairwise.D{f};
    Peaks = D(LocalMaxInd);
    Peaks
    KeepInd = find(Peaks>5 & Peaks<15,1,'First');
    legend([num2str(Peaks(KeepInd)) ' bp']);
end
