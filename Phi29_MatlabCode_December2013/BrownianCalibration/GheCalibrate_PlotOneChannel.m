function GheCalibrate_PlotOneChannel(Result,MainAxes,ResidualAxes,Color,LineWidth,MarkerSize,BoxHandle)
        x = Result.BlockFrequency; %raw data
        y = Result.BlockPower;     %raw data
        X = Result.FitFrequency;   %fit data
        Y = Result.FitPower;       %fit data

        plot(MainAxes,x,y,'.','MarkerSize',MarkerSize,'Color',Color); hold on;
        plot(MainAxes,X,Y,'-k','LineWidth',LineWidth);
        set(MainAxes,'YLim',[min(y)/1.4 max(y)*1.4]);
        set(MainAxes,'XLim',[min(x)/1.2 max(x)*1.2]);

        temp = y./Y;
        plot(ResidualAxes,x,temp,'.','MarkerSize',MarkerSize,'Color',Color);
        plot(ResidualAxes,X,ones(size(X)),'-k','LineWidth',LineWidth);
        set(ResidualAxes,'YLim',[min(temp)/1.1 max(temp)*1.1]);
        set(ResidualAxes,'XLim',[min(x)/1.2 max(x)*1.2]);
        
        BoxString = ['f_{c} = '    num2str(Result.fc,            '%5.0f') ' Hz \newline' ...
                     'k = '        num2str(Result.TrapStiffness, '%1.3f') ' pN/nm \newline' ...
                     '{\alpha} = ' num2str(Result.DetectorCalib, '%4.0f') ' nm/NV \newline' ...
                     'a*k = ' num2str(Result.DetectorCalib * Result.TrapStiffness, '%4.2f') 'pN/NV \newline' ];
        set(BoxHandle,'String',BoxString);

end