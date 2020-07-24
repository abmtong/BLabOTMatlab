function BestDataInd = PWD_GenerateDiagnosticPlots_ForCroppedFiles()
% This function is similar to PWD_GenerateDiagnosticPlots, except that it
% generates the PWD plots only for the portion of the trace that falls
% within the CroppedRegion defined by the *CROP file in the CropFiles
% folder. Traces with no Crop file will be skipped. 
% In addition, this function will look at the "contrast" of the PWD curve.
% If the contrast is higher than the threshold, the FeedbackCycle passes
% the test and is good enough to be used for StepFinding. This function
% will offer to save the good index to a text file which can be used right
% away for step-finding
%
% USE: BestDataInd = PWD_GenerateDiagnosticPlots_ForCroppedFiles()
%
% Gheorghe Chistol, 02 June 2011

%% Ask for parameters
Prompt = {'Data Acquisition Bandwidth (Hz)', ...
          'Filter Frequency (Hz)'          , ...
          'Histogram Bin Width (bp)'       , ...
          'Display Distance Range (bp)'    , ...
          'PWD Contrast Threshold (~1.5 works well)'};
Title = 'Enter the Following Parameters';
Lines = 1;
Default = {'2500','100','.5','40','1.2'};
Options.Resize='on'; Options.WindowStyle='normal'; Options.Interpreter='tex';
Answer = inputdlg(Prompt, Title, Lines, Default, Options);
Bandwidth     = str2num(Answer{1});
F             = str2num(Answer{2}); %this is the desired filter frequency
HistBinWidth  = str2num(Answer{3});
DistanceRange = str2num(Answer{4});
Filter        = round(Bandwidth/F); %filtering factor
ContrastThr   = str2num(Answer{5}); %this is a threshold for the PWD quality, the higher this number, the more rigurous the selection

AddMainCodePath; %make the rest of the function available
global analysisPath; %set the analysis path if neccessary
if isempty(analysisPath)
    disp('analysisPath was not previously defined. Please define it and try again.'); return;
end

File = uigetfile([ [analysisPath filesep] 'phage*.mat'], 'Please Selecte Phage Traces for PWD Diagnostics:','MultiSelect', 'on');
if isempty(File) %if no files were selected
    disp('No *.mat phage files were selected'); return;
end

if ~iscell(File) %if there is only one file, make it into a cell, for easier processing later
    temp=File; clear File; File{1}=temp;
end

%% Go through each trace and generate PWDs
%BestDataInd = []; %data structure to save the best feedback cycles
clear BestDataInd;
BestDataInd.PhageTrace = '';
BestDataInd.FeedbackCycle = '';

for p=1:length(File) %p is the phage index
    CropFile = [analysisPath filesep 'CropFiles' filesep File{p}(6:end-4) '.crop'];
    if ~exist(CropFile,'file') %if the crop file doesn't exist
        disp([File{p} ' was skipped, it has no CROP file']);
    else %proceed to generate PWDs
        disp(['Generating PWD plots for ' File{p}]);
        StartT=tic; %start the timer to measure the duration of calculation
        load([analysisPath filesep File{p}]);
        phage=stepdata; clear stepdata;
        
        FID = fopen(CropFile); %open the *.crop file
        Tstart = sscanf( fgetl(FID),'%f'); %parse the first line, which is the start time
        Tstop  = sscanf( fgetl(FID),'%f'); %parse the second line, which is the stop time
        fclose(FID);

        SelectedFeedbackCycles=[]; %FCs that we want to have PWDs for
        for fc=1:length(phage.time) %fc is the index of Feedback Cycles
            if min(phage.time{fc})>Tstart && max(phage.time{fc})<Tstop
                %this FC will be used in its entirety
                SelectedFeedbackCycles(end+1)=fc;
            end
        end

        for fc_index=1:length(SelectedFeedbackCycles); %fc is the index of feedback cycles
            fc = SelectedFeedbackCycles(fc_index); %currend feedback cycle index
            T  = BoxcarFilter(phage.time{fc},    Filter); %do a boxcar filter for smoother PWD
            L  = BoxcarFilter(phage.contour{fc}, Filter);

            if range(T)>0.5 %only look at the feedback traces longer than 0.5 sec
                %where the PWD window starts and ends
                PWD.Start(fc)  = L(1);
                PWD.Finish(fc) = L(end);
                HistogramBins  = min(L):HistBinWidth:max(L); %define the bins for the data, later used to calculate the PWD
                [N, D]         = GhePairWiseDistribution(L,HistogramBins);
                Ind=find(D>DistanceRange,1);
                if ~isempty(Ind)
                    N=N(1:Ind);
                    D=D(1:Ind);
                    N = N/sum(N); %normalize
                    Verdict = 'Fail'; %the verdict for the PWD contrast test, the default is Fail 
                    % Now it's time to calculate the contrast
                    ValleyInd0 = D>1  & D<9;  % look for the zeroth peak
                    PeakInd1   = D>7  & D<12; % look for the first peak
                    ValleyInd1 = D>12 & D<18; % look for the first valley
                    PeakInd2   = D>17 & D<22; % look for the second peak
                    ValleyInd2 = D>22 & D<28; % look for the second valley
                    if sum(ValleyInd0)~=0 && sum(ValleyInd1)~=0 && sum(ValleyInd2)~=0 && sum(PeakInd1)~=0 && sum(PeakInd2)~=0
                        Ntemp    = N(ValleyInd0); 
                        Dtemp    = D(ValleyInd0);
                        Nvalley0 = min(Ntemp); 
                        Dvalley0 = Dtemp(Ntemp==min(Ntemp)); Dvalley0=Dvalley0(1);
                        Ntemp    = N(ValleyInd1); 
                        Dtemp    = D(ValleyInd1);
                        Nvalley1 = min(Ntemp); 
                        Dvalley1 = Dtemp(Ntemp==min(Ntemp)); Dvalley1=Dvalley1(1);
                        Ntemp    = N(ValleyInd2); 
                        Dtemp    = D(ValleyInd2);
                        Nvalley2 = min(Ntemp); 
                        Dvalley2 = Dtemp(Ntemp==min(Ntemp)); Dvalley2=Dvalley2(1);
                        Ntemp  = N(PeakInd1); 
                        Dtemp  = D(PeakInd1);
                        Npeak1 = max(Ntemp); 
                        Dpeak1 = Dtemp(Ntemp==max(Ntemp)); Dpeak1=Dpeak1(1);
                        Ntemp  = N(PeakInd2); 
                        Dtemp  = D(PeakInd2);
                        Npeak2 = max(Ntemp); 
                        Dpeak2 = Dtemp(Ntemp==max(Ntemp)); Dpeak2=Dpeak2(1);
                        
                        Nbase1 = interp1([Dvalley0 Dvalley1],[Nvalley0 Nvalley1],Dpeak1); %the baseline for Peak1
                        Nbase2 = interp1([Dvalley1 Dvalley2],[Nvalley1 Nvalley2],Dpeak2); %the baseline for Peak1
                        Contrast1 = Npeak1/Nbase1; %contrast for the first peak
                        Contrast2 = Npeak2/Nbase2; %contrast for the second peak
                        if Contrast1>ContrastThr && Contrast2>ContrastThr
                            %PWD Contrast is high enough to pass the Test
                            Verdict = 'Pass';
                        end
                    end
                       
                    
                    h=figure; hold on; 
                    
                    if strcmp(Verdict,'Pass')
                        area(D,N,'LineWidth',1,'FaceColor',[0.8 0.8 1]); %to get the PWD, plot Number versus Distance
                        legend(['PASSED :), Contrast1=' num2str(Contrast1) ' Contrast2=' num2str(Contrast2) ' Thr=' num2str(ContrastThr)]);
                        % save the index to BestDataInd
                        if ~strcmp(BestDataInd(end).PhageTrace,File{p})
                            %new file has to be added to the list
                            BestDataInd(end+1).PhageTrace  = File{p};
                            BestDataInd(end).FeedbackCycle = fc;
                        else
                            BestDataInd(end).FeedbackCycle(end+1) = fc;
                        end

                    else
                        area(D,N,'LineWidth',1,'FaceColor',[1 0.6 0.8]); %to get the PWD, plot Number versus Distance
                        legend(['FAILED :(, Contrast1=' num2str(Contrast1) ' Contrast2=' num2str(Contrast2) ' Thr=' num2str(ContrastThr)]);
                    end
                    % Plot a marker at the zeroth minimum, first minimum, second minimum
                    plot(Dvalley0,Nvalley0,'.k','MarkerSize',15);
                    plot(Dvalley1,Nvalley1,'.k','MarkerSize',15);
                    plot(Dvalley2,Nvalley2,'.k','MarkerSize',15);
                    % Plot a marker at the first and second peaks
                    plot(Dpeak1,Npeak1,'.r','MarkerSize',15);
                    plot(Dpeak2,Npeak2,'.r','MarkerSize',15);
                    % Plot the baseline of first peak, and the second peak
                    plot([Dvalley0 Dvalley1],[Nvalley0 Nvalley1],'-k');
                    plot([Dvalley1 Dvalley2],[Nvalley1 Nvalley2],'-k');
                    % Plot the height of the first/second peaks above their baselines
                    plot(Dpeak1*[1 1],[Nbase1 Npeak1],'-r','LineWidth',2);
                    plot(Dpeak2*[1 1],[Nbase2 Npeak2],'-r','LineWidth',2);
                    
                    
                    YLim=get(gca,'YLim'); YLim(1)=0;
                    for n=1:round(DistanceRange/10)-1 %plot dotted lines every 10 bp
                        plot([n*10 n*10],YLim,':','Color',[.5 .5 .5]);
                    end
                    set(gca,'XLim',[0 DistanceRange]); %for consistency and ease of review
                    set(gca,'YLim',YLim,'Box','on');
                    xlabel('Distance (bp)'); ylabel('Normalized PWD');
                    title(['Trace: ' phage.file(1:end-4) ', Feedback Cycle: ' num2str(fc) ]);
                    
                    
                    if strcmp(Verdict,'Pass') %save good trace images into the "Good" folder
                        ImgFolder = [analysisPath filesep 'PWD_DiagnosticPlots' filesep 'Good'];
                        if ~isdir(ImgFolder); 
                            mkdir(ImgFolder); 
                        end 
                        saveas(h, [ImgFolder filesep phage.file(1:end-4) '_' num2str(fc)], 'png'); %save as both PNG and FIG for convenience
                        saveas(h, [ImgFolder filesep phage.file(1:end-4) '_' num2str(fc)], 'fig');
                        close(h);
                    else %save bad trace images into the "Bad" folder
                        ImgFolder = [analysisPath filesep 'PWD_DiagnosticPlots' filesep 'Bad'];
                        if ~isdir(ImgFolder); 
                            mkdir(ImgFolder); 
                        end 
                        saveas(h, [ImgFolder filesep phage.file(1:end-4) '_' num2str(fc)], 'png'); %save as both PNG and FIG for convenience
                        saveas(h, [ImgFolder filesep phage.file(1:end-4) '_' num2str(fc)], 'fig');
                        close(h);
                    end
                else
                    disp(['Feedback Trace #' num2str(fc) ' of ' phage.file(1:end-4) ' was skipped, does not cover enough']);
                end
            else
                disp(['Feedback Trace #' num2str(fc) ' of ' phage.file(1:end-4) ' was skipped due to insufficient data.']);
            end   
        end
        ElapsedT=toc(StartT);
        disp(['It took ' num2str(ElapsedT) ' sec to generate PWD Diagnostic Plots for ' phage.file(1:end-4)]);
    end
end

%% Now save the BestDataInd to an index text file for StepFinding 
%the first entry in BestDataInd is junk, discard
BestDataInd(1)='';

%save if there is anythign to save
if ~isempty(BestDataInd)
options.Interpreter = 'tex'; options.Default = 'Yes, Save Index';
qstring = 'Do you want to save the Index of the Best Feedback Cycles to a file?';
choice = questdlg(qstring,'Save File?','Yes, Save Index','No',options);
    if  strcmp(choice,'Yes, Save Index');
        [IndexFile,IndexFilePath] = uiputfile([analysisPath filesep 'BestStepIndexAuto_.txt'],'Save the Index of the Best Feedback Cycles');
        FID = fopen([IndexFilePath filesep IndexFile], 'wt+');
        for i=1:length(BestDataInd);
            line = [BestDataInd(i).PhageTrace(6:end-4) '  '];
            for j=1:length(BestDataInd(i).FeedbackCycle);
                line = [line ' ' num2str(BestDataInd(i).FeedbackCycle(j))];
            end
            fprintf(FID,'%s \n',line);
        end
        fclose(FID);
    end
end