function z_Review_ATPgS_ValidPauseClusters_21Oct2011()
% This is a makeshift function to look over validated pause clusters
% The whole point is to see what the burst size is before a pause cluster
% (as opposed to an individual pause). I have a hunch that we only get
% pause clusters when ATP-g-S binds to the special subunit.
%
% We can tag the pause-clusters that are nice and well-defined, then we can
% apply our cluster analysis to that.
%
% Gheorghe Chistol, 21 October 2011

%define our cluster span selection criteria
MinClusterSpan = 7;
MaxClusterSpan = 23;

%     PauseClusters{2}{6}(1)
% 
%     ans = 
% 
%           StartDwellInd: 2
%          FinishDwellInd: 2
%             ClusterSpan: 0
%         ClusterDuration: 2.1920
%                 IsValid: 1

%     FinalDwells{1}{1}
% 
%     ans = 
% 
%                 Start: [1x16 double]
%                Finish: [1x16 double]
%             StartTime: [1x16 double]
%            FinishTime: [1x16 double]
%             DwellTime: [1x16 double]
%         DwellLocation: [1x16 single]
%              StepSize: [1x16 single]
%          StepLocation: [1x16 single]
%             PhageFile: [1x107 char]
%         FeedbackCycle: 14
%             Bandwidth: 250
%               RawCont: [1x5980 single]
%               RawTime: [1x5980 double]
%              FiltCont: [1x598 single]
%              FiltTime: [1x598 double]
% 
global analysisPath;

[File, Path] = uigetfile([analysisPath filesep '*_ValidatedClusters.mat'], 'Pick an MAT-file Containing Validated Pause Clusters','MultiSelect','off');
load([Path filesep File]);

for ph = 1:length(PauseClusters) %ph stands for PHage trace
    for fc = 1:length(PauseClusters{ph}) %fc stands for FeedbackCycle
        for pc = 1:length(PauseClusters{ph}{fc}) %pc stands for PauseCluster
            if ~isempty(PauseClusters{ph}{fc}(pc))
                if isfield(PauseClusters{ph}{fc}(pc), 'IsValid') %check if this field exists at all
                    if PauseClusters{ph}{fc}(pc).IsValid %we have a validated pause cluster on our hands
                        CurrClusterSpan = PauseClusters{ph}{fc}(pc).ClusterSpan;

                        if CurrClusterSpan > MinClusterSpan && CurrClusterSpan < MaxClusterSpan
                            %consider only clusters with a span of 10 or 20 bp
                            x = FinalDwells{ph}{fc}.RawTime;
                            y = FinalDwells{ph}{fc}.RawCont;
                            X = FinalDwells{ph}{fc}.FiltTime;
                            Y = FinalDwells{ph}{fc}.FiltCont;
                            figure; hold on
                            plot(x,y,'Color',0.7*[1 1 1],'LineWidth',1);
                            plot(X,Y,'Color','b','LineWidth',1);

                            %Now Plot only the dwells within the pause cluster
                            LadderX = []; LadderY = [];
                            for d = PauseClusters{ph}{fc}(pc).StartDwellInd:PauseClusters{ph}{fc}(pc).FinishDwellInd 
                                LadderY(end+1:end+2) = FinalDwells{ph}{fc}.DwellLocation(d)*[1 1];
                                LadderX(end+1:end+2) = [FinalDwells{ph}{fc}.StartTime(d) FinalDwells{ph}{fc}.FinishTime(d)];
                            end
                            plot(LadderX,LadderY,'r','LineWidth',2);
                            set(gca,'XLim',[min(x) max(x)]);
                            set(gca,'YLim',[min(y) max(y)]);
                            set(gcf,'Units','Normalized','Position',[0.0059 0.0625 0.4883 0.8359]);
                            title('Trace Overview');
                            TempFile = [pwd filesep 'TempPlot.fig'];
                            saveas(gcf,TempFile,'fig');
                            uiopen(TempFile,1);
                            set(gcf,'Units','Normalized','Position',[0.5059 0.0625 0.4883 0.8359]);
                            title('Zoomed Into the Beginning');
                            temp = PauseClusters{ph}{fc}(pc).StartDwellInd; %the index of the dwell where the pause cluster starts
                            set(gca,'XLim',[FinalDwells{ph}{fc}.StartTime(temp)-1 FinalDwells{ph}{fc}.StartTime(temp)+1]);
                            set(gca,'YLimMode','auto');

                            % Ask if this is a good cluster for the purpose of our analysis1
                            Response = questdlg('Is this a suitable Pause Cluster?', 'Cluster Selection','Yes','No','No');
                            % Handle response
                            if strcmp(Response,'Yes')
                                PauseClusters{ph}{fc}(pc).ConsiderForSpecialSubunitAnalysis = 1;
                            else
                                PauseClusters{ph}{fc}(pc).ConsiderForSpecialSubunitAnalysis = 0;
                            end

                            close gcf; %close both figures that we just created
                            close gcf;
                        end
                    end
                end
            end
        end
    end
end

save([Path filesep File(1:end-4) '_SpecialSubunitAnalysis.mat'],'FinalDwells','PauseClusters');
end %the end of the current function