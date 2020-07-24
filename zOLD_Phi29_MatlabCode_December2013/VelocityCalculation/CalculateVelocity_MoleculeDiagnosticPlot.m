function CalculateVelocity_MoleculeDiagnosticPlot(Data,PlotFilePath,PlotFileName)
% This is an automated diagnostic plot generator that is used after a data file is put through the
% velocity calculation pipeline. It generates and saves a plot in the VelocityCalculation folder for
% later viewing. This function is called upon by CalculateVelocity
%
% USE: CalculateVelocity_MoleculeDiagnosticPlot(Data,PlotFilePath,PlotFileName)
%
% Gheorghe Chistol, 23 Feb 2012
    
    VelMean      = [];
    VelSigma     = [];
    ForceMean    = [];
    ForceStart   = [];
    ForceFinish  = [];
    TimeSpan     = [];
    ContourMean  = [];
    ContourSpan  = [];

    for fc = 1:length(Data);
        for v = 1:length(Data(fc).Velocity.VelocityValue)
            VelMean(end+1)     = Data(fc).Velocity.VelocityValue(v); %#ok<*AGROW>
            VelSigma(end+1)    = range(Data(fc).Velocity.FitConfInt{v}(:,1))/2;
            ForceMean(end+1)   = Data(fc).Velocity.ForceMean(v);
            ForceStart(end+1)  = Data(fc).Velocity.ForceStart(v);
            ForceFinish(end+1) = Data(fc).Velocity.ForceFinish(v);
            TimeSpan(end+1)    = Data(fc).Velocity.TimeSpan(v);
            ContourMean(end+1) = Data(fc).Velocity.ContourMean(v);
            ContourSpan(end+1) = Data(fc).Velocity.ContourSpan(v);
        end
    end

    % Create a large 2x2 figure
    figure('Units','normalized','Position',[0.0059    0.0625    0.6962    0.8359]);
    set(gcf,'PaperPosition',[0 0 8 6]);
    
    %% Plot Force Range Coverage
    subplot(2,2,1); set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
    for v = 1:length(VelMean)
        x = [ForceStart(v) ForceFinish(v)];
        y = VelMean(v)*[1 1];
        plot(x,y,'r');
    end
    ExtraX = 0.1; ExtraY = 0.1; %amount of extra room on the sides
    XLim = [min(ForceStart) max(ForceFinish)];
    XLim = [XLim(1)-ExtraX*range(XLim) XLim(2)+ExtraX*range(XLim)];
    YLim = [min(VelMean)-range(VelMean)*ExtraY  max(VelMean)+ExtraY*range(VelMean)];
    set(gca,'XLim',XLim,'YLim',YLim);
    xlabel('Force (pN)','FontWeight','bold');
    ylabel('Velocity (bp/s)','FontWeight','bold');
    title(Data(1).FileName,'FontWeight','bold','FontSize',15);
    
    %% Plot Velocity vs Tether Contour Length
    subplot(2,2,2); set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
    for i = 1:length(VelMean);
        x = ContourMean(i)*[1 1];
        y = VelMean(i)*[1 1]+ VelSigma(i)*[-1 1];
        plot(x,y,'m');
    end
    xlabel('Tether Contour Length (bp)','FontWeight','bold');
    ylabel('Translocation Velocity (bp/sec)','FontWeight','bold');

    %% Plot Velocity vs Sigma
    subplot(2,2,3); set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
    plot(VelMean,VelSigma,'.k');
    ylabel('2{\sigma} Confidence Interval (bp/sec)','FontWeight','bold');
    xlabel('Velocity (bp/s)','FontWeight','bold');
    
    %% Plot VelocityConfidenceInterval versus TimeSpan
    subplot(2,2,4); set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
    plot(TimeSpan,VelSigma,'.b');
    xlabel('Time Span (s)','FontWeight','bold');
    ylabel('2{\sigma} Confidence Interval (bp/sec)','FontWeight','bold');
    
    %save the plot image
    if ~exist(PlotFilePath,'dir')
        mkdir(PlotFilePath);
    end
    
    disp('   Saving velocity diagnostic plot ...');
    saveas(gcf,[PlotFilePath filesep PlotFileName]);
    close(gcf);
    
end