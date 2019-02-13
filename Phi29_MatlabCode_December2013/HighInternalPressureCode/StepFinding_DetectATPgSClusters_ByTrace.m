function PauseClusters = StepFinding_DetectATPgSClusters_ByTrace(PhageTrace,SaveFolder,MinPause,MaxSeparation)
    % Look though the step-finding results of
    % StepFinding_KalafutVisscher_ATPgS() and redo the ATPgS cluster detection
    % (the original code had some issues). Load the trace, then analyze data
    % one feedback cycle at a time. Label the long pauses in red. Then attempt
    % to cluster consecutive pauses if they are closer than the specified
    % MaxSeparation.
    % Right now this function is a proof-of-principle. Come back to it and
    % update, incorporate it into something more functional/integrated/useable.
    %
    % USE: PauseClusters = StepFinding_DetectATPgSClusters_ByTrace(PhageTrace,SaveFolder)
    %      where PhageTrace = FinalDwells{ph}
    %
    % Gheorghe Chistol, 25 July 2011

    %MinPause      = 0.5; %minimum pause to be part of a GammaS cluster
    %MaxSeparation = 15;  %maximum separation between two long pauses that belong to the same GammaS cluste
    %PlotFiltFact  = 25;  %filter factor for plotting data
    
    %% Look at the data one Feedback Cycle at a Time
    for fc = 1:length(PhageTrace)
        if ~isempty(PhageTrace{fc}) && sum(isnan(PhageTrace{fc}.RawCont))==0 %skip if the feedback cycle is totally empty
            % make a new figure, 
            figure('Units','normalized','Position',[ 0.0029    0.0625    0.4941    0.8451]);
            axes('Position',[0.1067    0.0601    0.8800    0.8767],'Box','on','Layer','top');
            hold on;

            % plot raw data in light gray
            plot(PhageTrace{fc}.RawTime,PhageTrace{fc}.RawCont,'Color',rgb('LightGray'));
            set(gca,'XLim',[min(PhageTrace{fc}.RawTime) max(PhageTrace{fc}.RawTime)]);
            set(gca,'YLim',[min(PhageTrace{fc}.RawCont) max(PhageTrace{fc}.RawCont)]);
            % plot filtered data in dark gray
            plot(PhageTrace{fc}.FiltTime,PhageTrace{fc}.FiltCont,'LineWidth',2,'Color',rgb('DarkGray'));

            % plot the stepping data in blue
            SteppingX = zeros(length(PhageTrace{fc}.DwellLocation),1);
            SteppingY = zeros(length(PhageTrace{fc}.DwellLocation),1);
            LongDwellInd = []; %the index of all dwells longer than MinPause

            for d = 1:length(PhageTrace{fc}.DwellLocation)
                tempX = [PhageTrace{fc}.StartTime(d) PhageTrace{fc}.FinishTime(d)];
                tempY = PhageTrace{fc}.DwellLocation(d)*[1 1];
                SteppingX((2*d-1):2*d) = tempX;
                SteppingY((2*d-1):2*d) = tempY;

                % if the current dwell is long enough, mark it in orange
                if PhageTrace{fc}.DwellTime(d)>MinPause
                    plot(tempX,tempY,'Color',rgb('Red'),'LineWidth',4);
                    LongDwellInd(end+1) = d; %#ok<AGROW> %remember this and come back to it later to determine clusters
                else
                    plot(tempX,tempY,'Color','b','LineWidth',3);
                end
            end

            %plot the stepping ladder
            plot(SteppingX,SteppingY,'b','LineWidth',1);

            %% Now go through LongDwellInd and figure out the pause clusters
            PauseClusters{fc} = [];
            %PauseClusters{fc}(1).StartDwellInd   = [];
            %PauseClusters{fc}(1).FinishDwellInd  = [];
            %PauseClusters{fc}(1).ClusterDuration = [];
            %PauseClusters{fc}(1).ClusterSpan     = [];        
            
            CurrStatus = 'none'; %at the beginning we don't have a cluster yet
            for i = 1:length(LongDwellInd)
                if strcmp(CurrStatus,'none') %we just entered a pause cluster
                    CurrStatus = 'inside';
                    if isempty(PauseClusters{fc})
                        %the very first pause cluster in this feedback cycle
                        PauseClusters{fc}(1).StartDwellInd   = LongDwellInd(i);
                        PauseClusters{fc}(1).FinishDwellInd  = LongDwellInd(i); %we will update the FinishDwellInd as we go. If there are more pauses in this cluster, it will be update, if this is the last pause, then it won't be updated
                    else
                        PauseClusters{fc}(end+1).StartDwellInd = LongDwellInd(i); %#ok<*AGROW>
                        PauseClusters{fc}(end).FinishDwellInd  = LongDwellInd(i); %set this ahead of time, update as you go along
                    end

                    if i==length(LongDwellInd) 
                        %this is the last long dwell, therefore the end of the pause cluster to the best of our knowledge
                        CurrStatus = 'none';
                    end
                else %CurrStatus='inside' right now
                    %we might be continuing an already existing pause
                    %cluster (if we're close enough to the previous pause) or we might be beginning a new pause cluster
                    if MaxSeparation>abs(PhageTrace{fc}.DwellLocation(LongDwellInd(i))-PhageTrace{fc}.DwellLocation(LongDwellInd(i-1)))
                        %the separation between the current long pause and the previous long pause is less than Max Separation
                        PauseClusters{fc}(end).FinishDwellInd  = LongDwellInd(i); %update the finish to the best of our knowledge
                        CurrStatus='inside'; %still inside the cluster
                    else
                        %we are no longer inside a cluster, so the current pause becomes the start of a new cluster
                        PauseClusters{fc}(end+1).StartDwellInd = LongDwellInd(i); %#ok<*AGROW>
                        PauseClusters{fc}(end).FinishDwellInd  = LongDwellInd(i); %set this ahead of time, update as you go along
                        CurrStatus='inside';
                    end
                end
            end

            % update the ClusterDuration and Cluster Span values
            for pc = 1:length(PauseClusters{fc})
                PauseClusters{fc}(pc).ClusterSpan     = PhageTrace{fc}.DwellLocation(PauseClusters{fc}(pc).StartDwellInd)-PhageTrace{fc}.DwellLocation(PauseClusters{fc}(pc).FinishDwellInd);
                PauseClusters{fc}(pc).ClusterDuration = PhageTrace{fc}.FinishTime(PauseClusters{fc}(pc).FinishDwellInd)-PhageTrace{fc}.StartTime(PauseClusters{fc}(pc).StartDwellInd);
            end
            % Plot a yellow semi-transparent patch for every Pause Cluster
            for pc = 1:length(PauseClusters{fc})
                tempY = [PhageTrace{fc}.DwellLocation(PauseClusters{fc}(pc).StartDwellInd) PhageTrace{fc}.DwellLocation(PauseClusters{fc}(pc).FinishDwellInd)];
                tempX = [PhageTrace{fc}.StartTime(PauseClusters{fc}(pc).StartDwellInd) PhageTrace{fc}.FinishTime(PauseClusters{fc}(pc).FinishDwellInd)];
                redY = [min(tempY) max(tempY) max(tempY) min(tempY)];
                redX = [min(tempX) min(tempX) max(tempX) max(tempX)];
                RedPatch = patch(redX,redY,'r');
                set(RedPatch,'LineStyle','none','FaceAlpha',0.3);

                tempY = get(gca,'YLim');

                yellowY = [min(tempY) max(tempY) max(tempY) min(tempY)];
                yellowX = [min(tempX) min(tempX) max(tempX) max(tempX)];
                YellowPatch = patch(yellowX,yellowY,'y');
                set(YellowPatch,'LineStyle','none','FaceAlpha',0.3);
            end

            % create a folder like "phage020111N01" and save all images inside
            PhageFile = PhageTrace{fc}.PhageFile;
            FilesepInd = findstr(PhageFile,filesep);
            FilesepInd = FilesepInd(end);

            CurrSaveFolder = [SaveFolder filesep PhageFile(FilesepInd+1:end-4)];
            if ~exist(CurrSaveFolder,'dir')
                mkdir(CurrSaveFolder);
            end
            
            xlabel('Time (s)');
            ylabel('DNA Contour Length (bp)');
            title([PhageFile(FilesepInd+1:end-4) ', FC #' num2str(fc)],'Interpreter','none');
            
            % save the image as a PNG and FIG            
            saveas(gcf,[CurrSaveFolder filesep PhageFile(FilesepInd+1:end-4) '_FC' num2str(fc)],'png');
            saveas(gcf,[CurrSaveFolder filesep PhageFile(FilesepInd+1:end-4) '_FC' num2str(fc)],'fig');
            close(gcf);
        end
    end
end