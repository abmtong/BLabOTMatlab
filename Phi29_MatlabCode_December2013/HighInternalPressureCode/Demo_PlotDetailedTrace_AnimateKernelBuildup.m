function Demo_PlotDetailedTrace_AnimateKernelBuildup()
    % Plot raw data in gray, plot filtered data taking into account the
    % Standard Error to define the upper/lower limit. Then plot the Kernel
    % Density on the side.
    %
    % Gheorghe Chistol, 18 July 2011

    % Load the PhageData
    PhageData = LoadPhage;
    RawTime = PhageData.time;
    RawCont = PhageData.contour;
    FilterFactor = 15;
    
    %for fc=1:length(RawTime)
    for fc=10
        RawX = RawTime{fc};
        RawY = RawCont{fc};
        if ~isempty(RawY)            
            [FiltX   ~   ] = FilterAndDecimate_StErr(RawX,FilterFactor);
            [FiltY StErrY] = FilterAndDecimate_StErr(RawY,FilterFactor);            
        end
    end
    
    UpperBound = FiltY+StErrY;
    LowerBound = FiltY-StErrY;
    PatchX = [FiltX      FiltX(end:-1:1)     ];
    PatchY = [UpperBound LowerBound(end:-1:1)];
    figure('Units','normalized','Position',[0.0044    0.0625    0.8990    0.8451]);
    A = axes('Position',[0.0730    0.0709    0.6477    0.8906],'Box','on');
    B = axes('Position',[0.7296    0.0709    0.2630    0.8906],'Box','on');
    axes(A); hold on;
    plot(RawX,RawY,'Color',0.8*[1 1 1]);
    h=patch(PatchX,PatchY,'b');
    set(h,'FaceColor',0.6*[1 1 1],'EdgeColor',0.6*[1 1 1]);
    plot(FiltX,FiltY,'k')
    XLim = [min(RawX) max(RawX)];
    YLim = [min(RawY) max(RawY)];
    set(gca,'XLim',XLim,'YLim',YLim);
    xlabel('Time (s)');
    ylabel('Contour Length (bp)');
    title('Sample ATPgS Packaging Trace, Saturating ATP')
    axes(B); hold on;
    camroll(90);
    [KernelX KernelY] = KV_CalculateCustomKernelDensity(RawY,FilterFactor);
    area(KernelX,KernelY,'FaceColor',rgb('SkyBlue'));
    set(gca,'XLim',YLim,'YLim',[0 1.1]); %same vertical axes as the other plot
    set(gca,'XTick',[],'YTick',[]);
    LocalMaxInd = StepFinding_FindLocalMaxInd(KernelY);
    plot(KernelX(LocalMaxInd),KernelY(LocalMaxInd),'.b','MarkerSize',10);
    keyboard;
    axes(A);
    for m = 1:length(LocalMaxInd);
        temp = get(gca,'XLim');
        plot(temp,KernelX(LocalMaxInd(m))*[1 1],':k','LineWidth',0.5);
    end
    axes(B);
    for m = 1:length(LocalMaxInd);
        temp = get(gca,'YLim');
        plot(KernelX(LocalMaxInd(m))*[1 1],temp,':k','LineWidth',0.5);
    end
end