function Demo_PlotDetailedTrace()
    % Plot raw data in gray, plot filtered data taking into account the
    % Standard Error to define the upper/lower limit
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
    figure; hold on
    plot(RawX,RawY,'Color',0.8*[1 1 1]);
    h=patch(PatchX,PatchY,'b');
    set(h,'FaceColor',0.6*[1 1 1],'EdgeColor',0.6*[1 1 1]);
    plot(FiltX,FiltY,'k')
end