function tTest_Main()
% We detect the dwells and bursts using the tTest
%
% USE: tTest_Main()
%
% Gheorghe Chistol, 24 May 2012

    % Define parameters
    WindowSize = 10;
    AvgNum = 10;
    tTestThr = 1e-4;
    
    Results = [];
    
    global analysisPath;
    [IndexFile IndexFilePath] = uigetfile([ [analysisPath filesep] '*.txt'], 'Please select the Index File','MultiSelect', 'off');
    IndexFile                 = [IndexFilePath filesep IndexFile];

    if ~exist(IndexFile,'file') %if no files were selected or file doesn't exist
        disp('No Index File phage files were selected'); return;
    end

    [SelectedPhages SelectedFeedbackCycles] = tTest_LoadPhageList(IndexFile); %loads the index of the sub-traces that are good

    % Go Through Each Phage & Each Feedback Cycle and Find Steps
    for p=1:length(SelectedPhages) %index p stands for "phage" 
        CurrentPhageFileName = [analysisPath filesep 'phage' SelectedPhages{p} '.mat'];

        if ~exist(CurrentPhageFileName,'file') %if the phage data file does not exist
            disp(['!!! Phage Data File does not exist: ' CurrentPhageFileName]);
        else
            disp(['+ Analyzing Phage ' CurrentPhageFileName]);
            load(CurrentPhageFileName);
            PhageData = stepdata; clear stepdata; %calibrated data from the current trace

            % Run the Step Finding Routine for each Feedback Cycle of the phage trace
            for fc = 1:length(SelectedFeedbackCycles{p}) %index fc stands for "FeedbackCycle"
                clear Data; %start with a clean slate
                Data.Contour = PhageData.contour{SelectedFeedbackCycles{p}(fc)}; %unfiltered raw data
                Data.Time    = PhageData.time{SelectedFeedbackCycles{p}(fc)};
                Data = tTest_Bare(Data, AvgNum, WindowSize);
                XLim = [min(Data.Time) max(Data.Time)];
                YLim = [min(Data.Contour) max(Data.Contour)];

                figure('Units','normalized','Position',[0.0059 0.0625 0.4883 0.8359],'PaperPosition',[0 0 7 10]); 
                TopAxes = axes('Position',[0.1300 0.3614 0.7750 0.59]); hold on;
                plot(Data.Time,Data.Contour,'Color',0.8*[1 1 1]);
                plot(Data.FilteredTime,Data.FilteredContour,'Color','b');
                set(gca,'XLim',XLim,'YLim',YLim,'XTickLabel',[],'Box','on','Layer','top');
                ylabel('DNA Contour Length (bp)');
                title([SelectedPhages{p} 'FC=' num2str(SelectedFeedbackCycles{p}(fc)) '; tTestThr = ' num2str(tTestThr) ', tTestWin = ' num2str(WindowSize) 'pts, FilterFactor = ' num2str(AvgNum)]);

                BottomAxes = axes('Position',[0.1300 0.0648 0.7750 0.2903]); hold on;
                plot(Data.FilteredTime, Data.sgn,'-b');
                plot(XLim,tTestThr*[1 1],':r');
                set(gca,'YScale','log','XLim',XLim,'YLim',[min(Data.sgn) max(Data.sgn)],'Box','on','Layer','top');
                xlabel('Time (s)'); ylabel('tTest Significance');
                DwellsBursts = tTest_FindDwellsBursts(Data,tTestThr); % Find Transitions
                axes(TopAxes);
                plot(DwellsBursts.LadderTime,DwellsBursts.LadderContour,'-r','LineWidth',2);
                for b = 1:length(DwellsBursts.BurstDuration)
                    ind = [DwellsBursts.BurstStartInd(b) DwellsBursts.BurstFinishInd(b)];
                    plot(Data.FilteredTime(ind),DwellsBursts.DwellMean(b:b+1),'g','LineWidth',2);
                end
                
                ImageDir = [analysisPath filesep 'tTestScreenShots'];
                if ~exist(ImageDir,'dir')
                    mkdir(ImageDir);
                end
                ImageName = [ImageDir filesep 'phage' SelectedPhages{p} '_fc' num2str(SelectedFeedbackCycles{p}(fc)) '_tTestScreenShot.png'];
                saveas(gcf,ImageName,'png'); close(gcf);
                
                Results(end+1).PhageFile   = SelectedPhages{p};
                Results(end).FeedbackCycle = SelectedFeedbackCycles{p}(fc);
                Results(end).BasicData     = Data;
                Results(end).DwellsBursts  = DwellsBursts;
            end
        end
    end
    SaveFile = [IndexFile(1:end-4) '_tTestResults.mat'];
    save(SaveFile,'Results');
end