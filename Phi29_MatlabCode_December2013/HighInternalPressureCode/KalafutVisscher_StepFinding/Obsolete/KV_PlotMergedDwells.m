function KV_PlotMergedDwells(ValidatedDwells)
%
%
for d=1:length(ValidatedDwells)
    x = [ValidatedDwells(d).StartTime ValidatedDwells(d).FinishTime];
    y = [1 1]*ValidatedDwells(d).DwellLocation;

    plot(get(gca,'XLim'),y,':k','LineWidth',0.5);
    plot(x,y,'k','LineWidth',4);
end