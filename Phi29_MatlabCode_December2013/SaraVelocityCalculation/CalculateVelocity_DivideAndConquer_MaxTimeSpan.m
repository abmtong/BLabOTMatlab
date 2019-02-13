function Velocity = CalculateVelocity_DivideAndConquer_MaxTimeSpan(Data,ForceBoundaries,VelFiltFact,MinContSpan,MinNumPts,PlotOption,PlotSave)
% First we split the Slip/Pause Free Segments into force segments as defined by ForceBoundaries.
% Each segment should span at least MinContSpan basepairs of contour length and should contain at
% least MinNumPts of filtered data points. Very few data points leads to crappy fits. Very small
% contour span also leads to crappy fits. PlotOption='Plot' if you want to generate diagnostic plots
% to make sure velocity calculation is done properly (or if you want to spot any anomalies).
% PlotOption='NoPlot' if you want to just to the calculation (this is also faster). PlotSave is a
% structure that specifies where the velocity calculation diagnostics plot should be saved. If
% PlotSave is not specified, the plot will not be saved at all.
% PlotSave.FilePath = the folder where the plot image will be saved
% PlotSave.FileName = 'phage040212_fc13.png'; the exact file name
%
% USE: Velocity = CalculateVelocity_DivideAndConquer(Data,ForceBoundaries,VelFiltFact,MinContSpan,MinNumPts,PlotOption)
%      Velocity = CalculateVelocity_DivideAndConquer(Data,ForceBoundaries,VelFiltFact,MinContSpan,MinNumPts,PlotOption,PlotSave) 
%
% Gheorghe Chistol, 23 Feb 2012

    Velocity.VelocityValue   = [];
    Velocity.TimeStart       = [];
    Velocity.TimeFinish      = [];
    Velocity.TimeSpan        = [];
    Velocity.ForceStart      = [];
    Velocity.ForceFinish     = [];
    Velocity.ForceSpan       = [];
    Velocity.ForceMean       = [];
    Velocity.ContourStart    = [];
    Velocity.ContourFinish   = [];
    Velocity.ContourSpan     = [];
    Velocity.ContourMean     = [];
    Velocity.FilteredTime    = {};
    Velocity.FilteredForce   = {};
    Velocity.FilteredContour = {};
    Velocity.Fit             = {}; %
    Velocity.FitConfInt      = {}; %confidence interval for the fit
    Velocity.FitTime         = {}; %two time points: @ beginning and end
    Velocity.FitContour      = {}; %two contour points: @ beginning and end
    Velocity.ForceRange      = [];
    
    for fr = 1:length(ForceBoundaries)-1
        ForceRange.StartF(fr)  = ForceBoundaries(fr);
        ForceRange.FinishF(fr) = ForceBoundaries(fr+1); 
    end
    
    Velocity.ForceRange = ForceRange;
    
    if strcmp(PlotOption,'Plot')
        figure('Units','normalized','Position',[0.0059 0.0625 0.3463 0.8359],'PaperPosition',[0.25 0.25 5 8]); 
        subplot(2,1,1); hold on;
        plot(Data.Time,Data.Contour,'-','Color',0.8*[1 1 1]);
        
        ylabel('Contour Length (bp)');
        % plot the slippausefreesegments in yellow
        for s = 1:length(Data.SlipPauseFreeSegments.StartTime)
            Ts = Data.SlipPauseFreeSegments.StartTime(s);
            Tf = Data.SlipPauseFreeSegments.FinishTime(s);
            temp = Data.Time>Ts & Data.Time<Tf;
            plot(Data.Time(temp),Data.Contour(temp),'-y');
        end
        
        subplot(2,1,2); hold on;
        plot(Data.Time,Data.Force,'-','Color',0.8*[1 1 1]);
        
        % plot the slippausefreesegments in yellow
        for s = 1:length(Data.SlipPauseFreeSegments.StartTime)
            Ts = Data.SlipPauseFreeSegments.StartTime(s);
            Tf = Data.SlipPauseFreeSegments.FinishTime(s);
            temp = Data.Time>Ts & Data.Time<Tf;
            plot(Data.Time(temp),Data.Force(temp),'-y');
        end

        ylabel('Force (pN)'); xlabel('Time (s)');        
        subplot(2,1,1); hold on;
    end
    
    % This section corrects for splitting the trace when the 
    offset=0;
    CorrTime(1)=Data.LadderTime(1)+offset;
    CorrContour(1)=Data.LadderContour(1);
    for i=1:length(Data.LadderTime)-1
        if (Data.LadderTime(i)-Data.LadderTime(i+1))> 7
        %disp(i)
        offset=offset+Data.LadderTime(i)-Data.LadderTime(i+1)+(Data.LadderTime(i-2)-Data.LadderTime(i-1));
        %disp(offset)
        end
    CorrTime(i+1)=Data.LadderTime(i+1)+offset;
    CorrContour(i+1)=Data.LadderContour(i+1);
    end
    
    plot(Data.LadderTime,Data.LadderContour,'-','Color','b','LineWidth',2); % plots the DNA stepwise function
    %plot(CorrTime,CorrContour,'b','LineWidth',2);
   
    
    for s = 1:length(Data.SlipPauseFreeSegments.StartTime)
        StartTime  = Data.SlipPauseFreeSegments.StartTime(s);
        FinishTime = Data.SlipPauseFreeSegments.FinishTime(s);
        GoodInd    = Data.Time>StartTime & Data.Time<FinishTime;
        Time       = Data.Time(GoodInd);
        Contour    = Data.Contour(GoodInd);
        Force      = Data.Force(GoodInd);
        
        VelFiltTime    = CalculateVelocity_FilterAndDecimate(Time,    VelFiltFact); %filter using the appropriate filtering factor
        VelFiltContour = CalculateVelocity_FilterAndDecimate(Contour, VelFiltFact);
        VelFiltForce   = CalculateVelocity_FilterAndDecimate(Force,   VelFiltFact);
        
        for fr = 1:length(ForceRange.StartF)
            %break the trace up into force intervals
            if length(VelFiltTime)<MinNumPts
                ForceStartTime  = NaN;
                ForceFinishTime = NaN;
            else
                tempS = find(VelFiltForce>=ForceRange.StartF(fr) & VelFiltForce<ForceRange.FinishF(fr),1,'first');
                tempF = find(VelFiltForce>=ForceRange.FinishF(fr),1,'first');
                if  ~isempty(tempS) && ~isempty(tempF)
                    ForceStartTime  = VelFiltTime(tempS);
                    ForceFinishTime = VelFiltTime(tempF);
                elseif ~isempty(tempS) &&  isempty(tempF)
                    ForceStartTime  = VelFiltTime(tempS);
                    ForceFinishTime = VelFiltTime(end);
                elseif  isempty(tempS) && ~isempty(tempF)
                    ForceStartTime  = VelFiltTime(1);
                    ForceFinishTime = VelFiltTime(tempF);
                else
                    ForceStartTime  = NaN;    
                    ForceFinishTime = NaN;                    
                end                
            end

            KeepInd = (VelFiltTime>ForceStartTime) & (VelFiltTime<=ForceFinishTime); %if either time limit is NaN, KeepInd will all be zeros
            
            if (sum(KeepInd)>=MinNumPts) && (range(VelFiltContour(KeepInd))>=MinContSpan)    
                X = double(VelFiltTime(KeepInd));    %convert array to double so the fitting function doesn't complain
                Y = double(VelFiltContour(KeepInd));
                CurrVelFit = fit(X',Y','poly1'); %fit to a line
                ind        = length(Velocity.VelocityValue)+1; %the index used to save the data to the Velocity structure
                
                %organize all the results in the data structure that will be saved
                Velocity.VelocityValue(ind)   = -CurrVelFit.p1; %negative slope means positive translocation velocity
                Velocity.FilteredTime{ind}    = VelFiltTime(KeepInd);
                Velocity.FilteredForce{ind}   = VelFiltForce(KeepInd);
                Velocity.FilteredContour{ind} = VelFiltContour(KeepInd);
                Velocity.TimeStart(ind)       = Velocity.FilteredTime{ind}(1);
                Velocity.TimeFinish(ind)      = Velocity.FilteredTime{ind}(end);
                Velocity.TimeSpan(ind)        = range(Velocity.FilteredTime{ind});
                Velocity.ForceStart(ind)      = Velocity.FilteredForce{ind}(1);
                Velocity.ForceFinish(ind)     = Velocity.FilteredForce{ind}(end);
                Velocity.ForceSpan(ind)       = range(Velocity.FilteredForce{ind});
                Velocity.ForceMean(ind)       = mean(Velocity.FilteredForce{ind});
                Velocity.ContourStart(ind)    = Velocity.FilteredContour{ind}(1);
                Velocity.ContourFinish(ind)   = Velocity.FilteredContour{ind}(end);
                Velocity.ContourSpan(ind)     = range(Velocity.FilteredContour{ind});
                Velocity.ContourMean(ind)     = mean(Velocity.FilteredContour{ind});
                Velocity.Fit{ind}             = CurrVelFit; 
                Velocity.FitConfInt{ind}      = confint(CurrVelFit); 
                Velocity.FitTime{ind}         = [Velocity.TimeStart(ind) Velocity.TimeFinish(ind)];
                Velocity.FitContour{ind}      = CurrVelFit(Velocity.FitTime{ind});

                if strcmp(PlotOption,'Plot')
                    if rem(ind,2)==1
                        PlotColor = 'k';
                    else
                        PlotColor = 'm';
                    end
                    plot(Velocity.FilteredTime{ind}, Velocity.FilteredContour{ind},'.', 'Color', PlotColor);
                    plot(Velocity.FitTime{ind},      Velocity.FitContour{ind},     '-', 'Color', PlotColor, 'LineWidth',2); subplot(2,1,2); hold on;
                    plot(Velocity.FilteredTime{ind}, Velocity.FilteredForce{ind},  '-', 'Color', PlotColor, 'LineWidth',2); subplot(2,1,1); hold on;
                end
            end
        end
    end
    
    if strcmp(PlotOption,'Plot')
        subplot(2,1,1);
        set(gca,'Box','on','XLim',[min(Data.Time) max(Data.Time)],'YLim',[min(Data.Contour) max(Data.Contour)]);

        subplot(2,1,2);
        set(gca,'XLim',[min(Data.Time) max(Data.Time)],'YLim',[min(Data.Force) max(Data.Force)]);
        set(gca,'Box','on','YTick',ForceBoundaries,'YGrid','on');

        if nargin==7 %if the user wants to plot AND save the file
            if ~exist(PlotSave.FilePath,'dir')
                mkdir(PlotSave.FilePath);
            end
            subplot(2,1,1); title(PlotSave.FileName,'FontWeight','bold','Interpreter','none');            
            saveas(gcf,[PlotSave.FilePath filesep PlotSave.FileName]);
        end
        close(gcf);
    end
end