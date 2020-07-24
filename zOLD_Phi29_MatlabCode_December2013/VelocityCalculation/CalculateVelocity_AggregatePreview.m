function Results = CalculateVelocity_AggregatePreview()
% This function lets you pick one or more VelocityResults files, aggregates the results and plots
% the summary for a quick visual diagnostic. It also outputs the aggregated data in the Results data
% structure. It does not save the plot anywhere, so you can save it manually, or not save it at all.
%
% USE: Results = CalculateVelocity_PreviewVelResults()
%
% Results.VelMean
% Results.VelSigma this is actually the 95% confidence interval, so technically 2*Sigma
% Results.ForceMean
% Results.ForceStart
% Results.ForceFinish
% Results.TimeSpan
% Results.ContourMean
% Results.ContourSpan
% 
% Gheorghe Chistol, 14 Oct 2012

% load('mri.kon','-mat')
% S = load(filename, '-mat', variables) forces load to treat the file as a MAT-file, regardless of
% the extension. Specifying variables is optional.
%

% Data(#).Velocity
%                 VelocityValue
%                 TimeStart
%                 TimeFinish
%                 TimeSpan
%                 ForceStart
%                 ForceFinish
%                 ForceSpan
%                 ForceMean
%                 ContourStart
%                 ContourFinish
%                 ContourSpan
%                 ContourMean
%                 FilteredTime
%                 FilteredForce
%                 FilteredContour
%                 Fit
%                 FitConfInt
%                 FitTime
%                 FitContour
%                 ForceRange

global analysisPath;

[FileName, FilePath] = uigetfile([analysisPath filesep 'VelocityCalculation' filesep 'VelocityResults*.mat'],'MultiSelect','on');
if ~iscell(FileName)
    temp = FileName; clear FileName;
    FileName{1} = temp; clear temp;
end

    VelMean      = [];
    VelSigma     = [];
    ForceMean    = [];
    ForceStart   = [];
    ForceFinish  = [];
    TimeSpan     = [];
    ContourMean  = [];
    ContourSpan  = [];
    
for f = 1:length(FileName)
    temp = load([FilePath filesep FileName{f}]);
    Data = temp.Data; clear temp;
    
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
end
Results.VelMean      = VelMean;
Results.VelSigma     = VelSigma;
Results.ForceMean    = ForceMean;
Results.ForceStart   = ForceStart;
Results.ForceFinish  = ForceFinish;
Results.TimeSpan     = TimeSpan;
Results.ContourMean  = ContourMean;
Results.ContourSpan  = ContourSpan;

    %% Create a large 2x2 figure
    figure('Units','normalized','Position',[0.0059    0.0625    0.6962    0.8359]);
    set(gcf,'PaperPosition',[0 0 8 6]);
    
    %% Plot Force Range Coverage
    subplot(2,2,1);
    set(gca,'FontName','AvantGarde','NextPlot','add');
    for v = 1:length(VelMean)
        x = [ForceStart(v) ForceFinish(v)];
        y = VelMean(v)*[1 1];
        plot(x,y,'r');
    end
    ExtraX = 0.1; %amount of extra room on the sides
    XLim = [min(ForceStart) max(ForceFinish)];
    XLim = [XLim(1)-ExtraX*range(XLim) XLim(2)+ExtraX*range(XLim)];
    ExtraY = 0.1;
    YLim = [min(VelMean)-range(VelMean)*ExtraY  max(VelMean)+ExtraY*range(VelMean)];
    set(gca,'XLim',XLim,'YLim',YLim,'Box','on');
    xlabel('Force (pN)','FontWeight','bold');
    ylabel('Velocity (bp/s)','FontWeight','bold');
    %title(Data(1).FileName,'FontWeight','bold','FontSize',15);
    
    %% Plot VelocityConfidenceInterval versus TimeSpan
    subplot(2,2,4);
    set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
    plot(TimeSpan,VelSigma,'.b');
    xlabel('Time Span (s)','FontWeight','bold');
    ylabel('2{\sigma} Confidence Interval (bp/sec)','FontWeight','bold');

    %% Plot Velocity vs Sigma
    subplot(2,2,3);
    set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
    plot(VelMean,VelSigma,'.k');
    ylabel('2{\sigma} Confidence Interval (bp/sec)','FontWeight','bold');
    xlabel('Velocity (bp/s)','FontWeight','bold');

    %% Plot Vel vs Tether Contour Length
    subplot(2,2,2);
    set(gca,'FontName','AvantGarde','NextPlot','add','Box','on');
    for i = 1:length(VelMean);
        x = ContourMean(i)*[1 1];
        y = VelMean(i)*[1 1]+ VelSigma(i)*[-1 1];
        plot(x,y,'m');
    end
    %set(gca,'XLim',[-length(VelSigma)*0.05 length(VelSigma)*1.05]);

    xlabel('Tether Contour Length (bp)','FontWeight','bold');
    ylabel('Translocation Velocity (bp/sec)','FontWeight','bold');
end