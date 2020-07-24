function StepFinding_DetectATPgSClusters_PlotEntirePhageTrace(PhageTrace,SaveFolder,PauseClusters,MinPause)
    % Plot the entire trace with identified pause clusters on a seprate
    % plot for a "global view". Use only filtered data, the stepping ladder
    % and the highlighted patches. Using raw data on this scale is very
    % memory intensive
    %
    % Gheorghe Chistol, 26 July 2011

    % make a new figure, 
    figure('Units','normalized','Position', [0.0029 0.0625 0.4941 0.8451]);
    axes('Position',[0.1067 0.0601 0.8800 0.8767],'Box','on','Layer','top');
    hold on;
    
    % Look at the data one Feedback Cycle at a Time
    for fc = 1:length(PhageTrace)
        if ~isempty(PhageTrace{fc}) %skip if the feedback cycle is totally empty
            % plot filtered data in dark gray
            plot(PhageTrace{fc}.FiltTime,PhageTrace{fc}.FiltCont,'LineWidth',2,'Color',rgb('DarkGray'));

            %set(gca,'XLim',[min(PhageTrace{fc}.RawTime) max(PhageTrace{fc}.RawTime)]);
            %set(gca,'YLim',[min(PhageTrace{fc}.RawCont) max(PhageTrace{fc}.RawCont)]);

            % plot the stepping data in blue
            SteppingX = zeros(length(PhageTrace{fc}.DwellLocation),1);
            SteppingY = zeros(length(PhageTrace{fc}.DwellLocation),1);
            LongDwellInd = []; %the index of all dwells longer than MinPause

            for d = 1:length(PhageTrace{fc}.DwellLocation)
                tempX = [PhageTrace{fc}.StartTime(d) PhageTrace{fc}.FinishTime(d)];
                tempY = PhageTrace{fc}.DwellLocation(d)*[1 1];
                SteppingX((2*d-1):2*d) = tempX;
                SteppingY((2*d-1):2*d) = tempY;

                % if the current dwell is long enough, mark it in red
                if PhageTrace{fc}.DwellTime(d)>MinPause
                    plot(tempX,tempY,'Color',rgb('Red'),'LineWidth',4);
                    LongDwellInd(end+1) = d; %#ok<AGROW> %remember this and come back to it later to determine clusters
                else
                    plot(tempX,tempY,'Color','b','LineWidth',3); %plot regular dwells in thick blue lines
                end
            end

            %plot the stepping ladder
            plot(SteppingX,SteppingY,'b','LineWidth',1);
            
            % write down the # of the Feedback Cycle for reference
            X = min(SteppingX)+0.3*range(SteppingX);
            Y = max(SteppingY)-0.2*range(SteppingY);
            text(double(X),double(Y),['FC #' num2str(fc)],'FontSize',11);
        end 
    end
    
    YLim = get(gca,'YLim'); set(gca,'YLim',YLim); %set the YLim so it doesn't adjust automagically
    
    % go through all the pause clusters and highlight them in yellow and red
    for fc = 1:length(PauseClusters) %fc = feedback cycle index
        for pc = 1:length(PauseClusters{fc}) %pc = pause cluster index
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
    end

    % create a folder like "phage020111N01" and save all images inside
    PhageFile = PhageTrace{fc}.PhageFile;
    FilesepInd = findstr(PhageFile,filesep);
    FilesepInd = FilesepInd(end);

    xlabel('Time (s)');
    ylabel('DNA Contour Length (bp)');
    title([PhageFile(FilesepInd+1:end-4) ' Entire Cropped Trace'],'Interpreter','none');

    % save the image as a PNG and FIG            
    saveas(gcf,[SaveFolder filesep PhageFile(FilesepInd+1:end-4) '_EntireTrace' ],'png');
    saveas(gcf,[SaveFolder filesep PhageFile(FilesepInd+1:end-4) '_EntireTrace' ],'fig');
    close(gcf);

end