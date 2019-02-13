function PWD = PWD_CalculateForSingleFeedbackCycle(PhageFolder,PhageFile,PhageFeedbackCycleList,HistBinWidth,Filter)
% This function is given a phage and a list of selected feedback cycles. It
% then calculates the Pairwise Distribution probability for each feedback
% cycle separately (treating it as a separate window). This works with
% PWD_ProcessIndexFile.m
%
% Filter - the filtering factor Filter = round(2500/FilterFreq)
%
% How to read the PWD results data structure:
% PWD is calculated in windows. Each window is defined by the DNA contour 
% length at the "Start" and "Finish" of the window.
% The actual PWD results are contained in the "Number" and "Distance" fields
% plot(PWD.Distance{i},PWD.Number{i}) will plot the PWD graph you expect
% "Segment" is the length of the actual window used to calculate the PWD
% (very close to the specified value)
% "Location" specifies the position of the portion of DNA used to calculate PWD
% in this particular window (middle of the piece, used for sorting PWD results 
% as a function of capsid filling)
% "Time" and "Contour" refer to the (filtered) DNA contour length as a function of
% time for this particular window of data.
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
%
% USE: PWD = PWD_CalculateForSingleFeedbackCycle(PhageFolder,PhageFile,PhageFeedbackCycleList,HistBinWidth,Filter)
%
% Gheorghe Chistol, 18 Nov 2010

% PhageFolder - complete name of the folder where the PhageFile is located
% PhageFile - Name of the *.mat file with the Phage Data
% PhageFeedbackCycleList - list of feedback cycles to include in the calculation
% HistBinWidth - The width of the bin for PWD calculation: ~0.2-0.5bp
% SaveFolder - name of the folder where the PWD results will be saved
% SaveFile   - name of the file where PWD results are saved
% there is no need for the crop file here, since the phage and feedback
% cycles are specified

% 1.Filter the data and merge it in a single vector
% 2.Split the data vector into several windows
% 3.Calculate the PWD within each of those windows
disp('--------------------');        
disp(['Calculating PWD for ' PhageFile]);
StartT=tic; %start the timer to measure the duration of calculation
load([PhageFolder '\' PhageFile]); %load the specified phage file
Trace     = stepdata; clear stepdata; %load the data and clear intermediate data
RemoveInd = [];

%% Compile the Time vector and the Length vector for the current FeedbackCycle
for fc=1:length(PhageFeedbackCycleList); %go through the list of selected feedback cycles
    CurrentFC = PhageFeedbackCycleList(fc); %current feedback cycle
    T = FilterAndDecimate(Trace.time{CurrentFC},Filter); %#ok<*AGROW>
    L = FilterAndDecimate(Trace.contour{CurrentFC},Filter);

    if range(T)>1 %only look at the feedback traces longer than 1 sec

        %where the PWD window starts and ends
        %in our case the PWD window is simply the current feedback cycle
        PWD.Start(fc)  = L(1);
        PWD.Finish(fc) = L(end);
            %now calculate the PWD for this window
        %define the bins for the data, later used to calculate the PWD
        TempL = L; %(StartInd:FinishInd); %the contour length data for this window
        TempT = T;%(StartInd:FinishInd); %the time data for this window
        HistogramBins = min(TempL):HistBinWidth:max(TempL);

        [N, D] = GhePairWiseDistribution(TempL,HistogramBins);
        %PWD.Number{fc}  = N;
        %PWD.Distance{fc}= D; 
        
        XLimit = 100;
        IndKeep = D<XLimit;
        CroppedN = N(IndKeep);
        CroppedN = CroppedN/sum(CroppedN); %normalize
        CroppedD = D(IndKeep);
        
        %calculate std/mean as a measure of "wiggliness"
        IndLarger = CroppedD>10; %find everything larger than 10
        LimitedN = CroppedN(IndLarger);
        Score = std(LimitedN)/mean(LimitedN);
        h=figure;
        plot(CroppedD,CroppedN,'-b');
        set(gca,'XLim',[0 XLimit]);
        xlabel('Distance (bp)');
        ylabel('PWD Probability');
        title(['Trace: ' PhageFile ', Feedback Cycle: ' num2str(CurrentFC) ' Score: ' num2str(Score) ]);
        %to get the PWD, plot Number versus Distance
        
        ImgFolder = [PhageFolder '\' 'PWD_Results_Images'];
        if ~isdir(ImgFolder);
            mkdir(ImgFolder);%create the directory
        end
        saveas(h, [ImgFolder '\' PhageFile(1:end-4) '_' num2str(CurrentFC)], 'png');
        close(h);
        
        PWD.Number{fc}  = CroppedN;
        PWD.Distance{fc}= CroppedD; 
        
        PWD.SegmentLength(fc) = abs(PWD.Start(fc)-PWD.Finish(fc)); %the length of the packaged DNA segment
        PWD.Location(fc)= mean(TempL); %where along DNA where this feedback cycle is located
        PWD.Time{fc}    = TempT;
        PWD.Contour{fc} = TempL;
    else
        disp(['Trace #' num2str(CurrentFC) ' was skipped due to insufficient data.']);
        RemoveInd = [RemoveInd fc]; %this feedback trace was discarded, remove it at the end
    end
    
end

ElapsedT=toc(StartT);
disp(['It took ' num2str(ElapsedT) ' sec to perform the PWD calculation']);

PWD.PhageFolder    = PhageFolder;
PWD.PhageFile      = PhageFile;
PWD.FeedbackCycles = PhageFeedbackCycleList;
PWD.FilterFactor   = Filter;
% if ~isdir(ImageFolderName);
%     mkdir(ImageFolderName);%create the directory
% end
% ImageFileName = [ImageFolderName '\' PhageData.file(1:end-4) '_' num2str(CurrentFeedbackCycle) '.png'];
% saveas(H,ImageFileName);
% close(H);

% disp(['! Feedback Cycle #' num2str(SelectedFeedbackCycles{p}(fc)) 'because it contains insuficient data']);


%         %% Save the Velocity Data in a separate file in a separate folder
%         Folder = [analysisPath '\' 'PWDData'];
%         if ~exist(Folder,'dir') %if this folder doesn't exist, create it
%             mkdir(Folder); %create it
%         end        
%         
%         FilePWD = [Folder '\' File{f}(1:end-4) '_pwd.mat'];
%         save (FilePWD, 'PWD'); %save data to a file
%         disp(['Saved file ' FilePWD ]); %show message in terminal
%        disp(['Data Saved to ' FilePWD]);