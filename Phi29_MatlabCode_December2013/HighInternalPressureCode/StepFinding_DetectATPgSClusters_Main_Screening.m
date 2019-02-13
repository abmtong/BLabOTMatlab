function StepFinding_DetectATPgSClusters_Main_Screening
% We take the pause cluster candidates identified by
% StepFinding_DetectATPgSClusters_Main and screen them visually. This is
% done to throw away weird stuff like hopping, or suspiciously looking
% pause clusters. We assign each pause cluster a pass/fail screening
% verdict and use this verdict later when tabulating the pause cluster
% duration/span. 
% This is done to accurately estimate the mean pause cluster duration
%
% Gheorghe Chistol, 21 September 2011

global analysisPath;
clear PauseClusters FinalDwells;
% select the step-finding-results file manually
% *_ResultsKV_DetectATPgSClusters_Main.mat
[File FilePath] = uigetfile([ [analysisPath filesep] '*_ResultsKV_DetectATPgSClusters_Main.mat'], ...
                                'Please select the file that contains Pause Cluster candidates','MultiSelect', 'off');
load([FilePath filesep File]);
%FinalDwells   = load([FilePath filesep File],'FinalDwells');
%PauseClusters = load([FilePath filesep File],'PauseClusters');

figure('Units','normalized','Position',[0.0059    0.0625    0.4883    0.8359]);
hold on;
FilterFactor = 10;
DeltaT = 0.5; %the extra time before/after the pause cluster to be displayed

%% Plot entire trace, plot step-ladder, highlight Pause Cluster Candidates
for ph = 1:length(PauseClusters) % ph refers to the phage index
    for fc = 1:length(PauseClusters{ph}) %fc refers to the feedback cycle index
        
        % plot the raw data in yellow
        if isfield(FinalDwells{ph}{fc},'RawTime') && isfield(FinalDwells{ph}{fc},'RawCont')
            plot(FinalDwells{ph}{fc}.RawTime,FinalDwells{ph}{fc}.RawCont,'y');
            hold on;
            X = FilterAndDecimate(FinalDwells{ph}{fc}.RawTime,FilterFactor);
            Y = FilterAndDecimate(FinalDwells{ph}{fc}.RawCont,FilterFactor);

            % plot the raw data within pause clusters in red
            if ~isempty(PauseClusters{ph}{fc})
                for pc = 1:length(PauseClusters{ph}{fc}) %pc refers to the pause cluster index for the specified ph & fc
                    StartDwellInd  = PauseClusters{ph}{fc}(pc).StartDwellInd;
                    FinishDwellInd = PauseClusters{ph}{fc}(pc).FinishDwellInd;
                    StartTime  = FinalDwells{ph}{fc}.StartTime(StartDwellInd);  %the current pause cluster starts here
                    FinishTime = FinalDwells{ph}{fc}.FinishTime(FinishDwellInd); %the current pause cluster ends here
                    RawInd = FinalDwells{ph}{fc}.RawTime>StartTime & FinalDwells{ph}{fc}.RawTime<FinishTime;
                    plot(FinalDwells{ph}{fc}.RawTime(RawInd),FinalDwells{ph}{fc}.RawCont(RawInd),'Color',rgb('Red'));
                end
            end

            %plot the filtered data in blue
            plot(X,Y,'b');
        end
    end
    set(gca,'Color','k','YGrid','on','YColor',0.2*[1 1 1]);
    xlabel('Time (s)'); ylabel('DNA Contour Length (bp)');
    temp = strfind(FinalDwells{ph}{end}.PhageFile,filesep); %find where '/' fileseparators are
    title(FinalDwells{ph}{end}.PhageFile(temp(end)+1:end));
    
    % Go through all Pause Cluster candidates, Pass or Fail them
    for fc = 1:length(PauseClusters{ph})
        for pc = 1:length(PauseClusters{ph}{fc})
            StartDwellInd  = PauseClusters{ph}{fc}(pc).StartDwellInd;
            FinishDwellInd = PauseClusters{ph}{fc}(pc).FinishDwellInd;
            StartTime  = FinalDwells{ph}{fc}.StartTime(StartDwellInd);  %the current pause cluster starts here
            FinishTime = FinalDwells{ph}{fc}.FinishTime(FinishDwellInd); %the current pause cluster ends here
            XLim = [StartTime-DeltaT FinishTime+DeltaT];
            set(gca,'XLim',XLim,'YLimMode','auto');
            
            %get the verdict from the keyboard
            Verdict = input('Pass/Fail this cluster candidate? [p/f]: ', 's');
            if strcmp(Verdict,'p')
                PauseClusters{ph}{fc}(pc).ScreeningVerdict = 1;
            else
                PauseClusters{ph}{fc}(pc).ScreeningVerdict = 0;
            end
        end
    end
    delete(gca);
end

%% Save the results and move on
disp('Saving the results of Pause Cluster screening ...');
save([FilePath filesep File(1:end-4) '_Screened.mat'],'FinalDwells','PauseClusters');
close(gcf);
end