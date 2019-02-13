function FigureH = KV_ATPgS_PlotEntireTrace(RawT,RawY,FiltT,FiltY,FinalDwells,CurrFC,FileName,analysisPath,FigureH)
    % Create a figure and plot the raw/filtered/step data as we accumulate more
    % and more feedback cycles worth of data
    %
    % Gheorghe Chistol, 7 July 2011
    
    if nargin==8
        %no figure has been created yet, create the figure
        FigureH = figure('Units','normalized','Position',[0.0029 0.0625 0.4941 0.8451]);
        set(gca,'Position',[0.0844 0.0663 0.9022 0.8860],'Box','on');
        title(FileName);
        hold on;
    end
    
	figure(FigureH); %work on this particular figure
    plot(RawT,RawY,'Color',rgb('LightGray'));
    plot(FiltT,FiltY,'Color',rgb('SlateGray'));

    text(double(FiltT(1)+0.1*range(FiltT)),double(FiltY(1)),['#' num2str(CurrFC)]);
    
    %% Plot the Dwell Candidates on the Left Plot (A1)
    x=[]; y=[];

    for d=1:length(FinalDwells.DwellLocation)
        tempx = [FinalDwells.StartTime(d)     FinalDwells.FinishTime(d)];  %beginning/end of the current dwell
        tempy = [FinalDwells.DwellLocation(d) FinalDwells.DwellLocation(d)];
        x(end+1:end+2) = tempx;
        y(end+1:end+2) = tempy;
        plot(tempx,tempy,'b','LineWidth',2);
    end
    plot(x,y,'-b','LineWidth',1);
end