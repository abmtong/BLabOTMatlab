function z_PlotResults(Dwell,ATP)
% Plot the results depending on filling
% z_PlotResults(Dwell,ATP)
% ATP = ATp concentration to use in the title, a number, uM

    TetherLength = 15025+6017; %21kb tether in bp
    GenomeLength = 19282; %in bp
    FillingBoundaries = [60 80 85 90 95 100];

    Dwell.Filling = 100*(TetherLength-Dwell.Location)/GenomeLength; %filling in percent
    
%     %plot the number of dwells at a given filling for this condition
%     BinSize = 5; %in percent
%     Bins = (50+BinSize/2):BinSize:110;
%     figure; hist(Dwell.Filling,Bins);
%     xlabel('Capsid Filling (%)');
%     ylabel('Number of Dwells');
%     set(findobj(gca,'Type','patch'),'FaceColor','m');
%     
%     if nargin==2
%         title(['High Resolution Data Coverage, 21kb Tether, [ATP] = ' num2str(ATP) ' {\mu}M']);
%         global analysisPath;
%         saveas(gcf,[analysisPath filesep 'HighResCoverage_21kb_' num2str(ATP) 'uM'], 'png');
%         saveas(gcf,[analysisPath filesep 'HighResCoverage_21kb_' num2str(ATP) 'uM'], 'fig');
%     else
%         title('High Resolution Data Coverage');
%     end
%     close gcf;
%     return;
%     
    figure;
    for f = 1:length(FillingBoundaries)-1
        LowerLim = FillingBoundaries(f);
        UpperLim = FillingBoundaries(f+1);
        KeepInd = Dwell.Filling>=LowerLim & Dwell.Filling<UpperLim;
        
        tempDwellDuration = Dwell.Duration(KeepInd);
        tempStepBefore    = Dwell.SizeStepBefore(KeepInd);
        tempStepAfter     = Dwell.SizeStepAfter(KeepInd);
        
        DwellBinSize = 0.1; 
        DwellBins    = DwellBinSize/2:DwellBinSize:10;
        
%         %%Plot the DwellDuration
%         subplot(length(FillingBoundaries)-1,1,f);
%         hist(tempDwellDuration,DwellBins);
%         %xlabel('Dwell Duration (s)');
%         %ylabel('Number of Dwells');
%         ylabel([ num2str(LowerLim) '-' num2str(UpperLim) '%']);
%         set(findobj(gca,'Type','patch'),'FaceColor','r');
%         set(gca,'XLim',[0 4]);
%         legend(sprintf('<Dwell>= %2.3f s \n', mean(tempDwellDuration)));
%         

        %%Plot the DwellDuration
        StepBinSize = 1; 
        StepBins    = StepBinSize/2:StepBinSize:20;
        subplot(length(FillingBoundaries)-1,1,f);
        hist(tempStepAfter,StepBins);
        %xlabel('Dwell Duration (s)');
        %ylabel('Number of Dwells');
        ylabel([ num2str(LowerLim) '-' num2str(UpperLim) '%']);
        set(findobj(gca,'Type','patch'),'FaceColor','b');
        set(gca,'XLim',[0 20]);
        %legend(sprintf('<Dwell>= %2.3f s \n', mean(tempDwellDuration)));
        

%         %Plot the StepAfterSize
%         StepBinSize = 1; 
%         StepBins    = -20:StepBinSize:20;
%         figure; hist(tempStepAfter,StepBins);
%         xlabel('Step Size (bp)');
%         ylabel('Number of Steps');
%         title(['Filling: ' num2str(LowerLim) '-' num2str(UpperLim) '%']);
%         set(findobj(gca,'Type','patch'),'FaceColor','g');
%         set(gca,'XLim',[-20 20]);
%         
%         %Plot StepBefore vs StepAfter
%         figure;
%         plot(tempStepBefore,tempStepAfter,'.b');
%         xlabel('Step Size Before (bp)');
%         ylabel('Step Size After (bp)');
%         title(['Filling: ' num2str(LowerLim) '-' num2str(UpperLim) '%']);
%         set(gca,'XLim',[-10 20]); set(gca,'YLim',[-10 20]);
%         
%         %Plot DwellDuration vs StepAfter
%         figure;
%         plot(tempDwellDuration,tempStepAfter,'.r');
%         xlabel('DwellDuration (s)');
%         ylabel('Step Size After (bp)');
%         title(['Filling: ' num2str(LowerLim) '-' num2str(UpperLim) '%']);
%         set(gca,'XLim',[-0 5]); set(gca,'YLim',[-10 20]);
        
    end
    xlabel('Step Size (bp)');
end