function BurstSize__Main_GUI_PlotNewDwellStaircase(Dwells)
% Once you calculate the new dwells, plot the dwell staircase plot with all
% the associated markings
%
% USE: BurstSize__Main_GUI_PlotNewDwellStaircase(Dwells)
%
% Gheorghe chistol, 22 Feb 2013

        axes(findobj(gcf,'Tag','PlotAxes')); hold on; %focus on the PlotAxes, hold plots
        %plot the new staircase plot
        delete(findobj(gcf,'Tag','StaircasePlot')); %delete the old filtered data plot
        h = plot(Dwells.StaircaseTime,Dwells.StaircaseContour,'-','Color','b','LineWidth',2.5); set(h,'Tag','StaircasePlot');
        %write the dwell durations labels
        delete(findobj(gca,'Tag','DwellDurationLabel'));%delete the old burst size labels
        delete(findobj(gca,'Tag','DwellLocationMark'));%delete the horizontal line marking dwell location
        for d=1:length(Dwells.DwellLocation)
            %first plot horizontal dashed lines to mark dwell location
            XLim = get(gca,'XLim');
            x = [Dwells.FinishTime(d) XLim(2)];
            y = Dwells.DwellLocation(d)*[1 1];
            h = plot(x,y,':k'); set(h,'Tag','DwellLocationMark');
            %now write the dwell duration next to each dwell
            %x = double(Dwells.FinishTime(d)+0.2);
            x = double(XLim(2)-0.12*range(XLim));
            y = double(Dwells.DwellLocation(d));
            DwellDuration = sprintf('%3.2f',Dwells.DwellDuration(d));
            h = text(x,y,[' ' DwellDuration ' s']); set(h,'Tag','DwellDurationLabel','FontWeight','bold','Color','b','BackgroundColor','w','EdgeColor','b','FontSize',12);
        end
        
        axes(findobj(gcf,'Tag','KernelAxes')); 
        %set(gca,'YGrid','on','YTick',sort(Trace.Dwells.DwellLocation));
        delete(findobj(gca,'Tag','BurstSizeLabel'));%delete the old burst size labels
        %diplay new burst size labels
        for d=1:length(Dwells.DwellLocation)-1
            x = -1.05;
            y = double(mean(Dwells.DwellLocation(d:(d+1))));
            BurstSize = sprintf('%2.2f',range(Dwells.DwellLocation(d:d+1)));
            h = text(x,y,[BurstSize ' bp']); set(h,'Tag','BurstSizeLabel','FontWeight','bold','FontSize',12);
        end
        %plot error bar marks at 2 sigma
        delete(findobj(gca,'Tag','ErrorBarMark'));
        delete(findobj(gcf,'Tag','DwellPlot'));
        for d=1:length(Dwells.DwellLocation)
            x = get(gca,'XLim');
            y = Dwells.DwellLocation(d)*[1 1];
            yerr = Dwells.DwellLocationErr(d)*[1 1];
            hold on;
            %h = plot(x,y+yerr,'-','Color',0.8*[1 1 1]); set(h,'Tag','ErrorBarMark');
            h = plot(x,y,':','Color',0*[1 1 1]); set(h,'Tag','ErrorBarMark');
            %h = plot(x,y-yerr,'-','Color',0.8*[1 1 1]); set(h,'Tag','ErrorBarMark');
        end
end