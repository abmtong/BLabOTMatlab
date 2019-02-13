function PlotBrokenYaxisHistogram(Data,Bins,YBreakStart,YBreakFinish,XLim,YLim,YTickIncrement)
    % USE:
    % PlotBrokenYaxisHistogram(Data,Bins,YBreakStart,YBreakFinish,XLim,YLim,YTickIncrement)
    Delta = 0.05*(range(YLim)-(YBreakFinish-YBreakStart));    
    PatchY = [YBreakStart YBreakStart+Delta ...
              YBreakStart YBreakStart+Delta ...
              YBreakStart YBreakStart+Delta ...
              YBreakStart YBreakStart+Delta ...
              YBreakStart YBreakStart+Delta ...
              ]; 
	PatchX = XLim(1):range(XLim)/9:XLim(2);
    
    tempY = [PatchY PatchY(end:-1:1)+Delta/1.5];
    tempX = [PatchX PatchX(end:-1:1)];
    
    figure; hold on;
    set(gca,'Box','on','Layer','bottom','FontSize',16);
    [N X] = hist(Data,Bins);
    
    for i = 1:length(N)
        if N(i)>YBreakStart
            N(i) = N(i)-(YBreakFinish-YBreakStart);
        end
    end
    bar(Bins,N,1);
    h=patch(tempX,tempY,'w');
    set(h,'LineStyle',':');
    xlabel('Pause Cluster Span (bp)');
    ylabel('Counts');
    set(gca,'XLim',XLim);
    set(gca,'YLim',[YLim(1) YLim(2)-range([YBreakStart YBreakFinish]) ] );
    YTickLabel = [YLim(1):YTickIncrement:YBreakStart YLim(2):-YTickIncrement:YBreakFinish];
    YTick      = [YLim(1):YTickIncrement:YBreakStart (YLim(2):-YTickIncrement:YBreakFinish)-(YBreakFinish-YBreakStart)+Delta/1.5];
    set(gca,'YTick',sort(YTick),'YTickLabel',sort(YTickLabel));
end