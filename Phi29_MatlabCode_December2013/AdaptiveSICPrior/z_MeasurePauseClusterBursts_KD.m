function PausingEvent = z_MeasurePauseClusterBursts_KD()
% This function loads an index file with start-stop times for various pause clusters. It then plots
% the kernel density corresponding to each pause cluster, which allows us to measure the bursts
% within those pause clusters. Measuring bursts in a pause cluster is very easy since the pauses are
% so long.
% We have a list of tagged pausing events in a text file that looks like this
% 052311N83 +4.38  %this +4.38 is the offset that needs to be applied to all time values within this trace (due to a stupid mistake)
% 	17.4-22.5
% 	101-102.6
% 	106.1-106.7
% 	118.8-136.1
%
% It contains the trace name and the StartTime-FinishTime in seconds

    close all; global analysisPath;
    Bandwidth    = 2500;
    FilterFactor = 25;
    PeakThr      = 1.2; %for peak detection in the Kernel Density

%% Load PauseIndex file and Parse the file to compile an index of pausing events
[IndexFileName IndexFilePath] = uigetfile([analysisPath filesep '*.txt'],'MultiSelect','off');
clear Index;
Index.PhageName  = []; %one phage may have more than one StartTime-FinishTime pairs
Index.TimeOffset = [];
Index.StartTime  = [];
Index.FinishTime = [];

FID = fopen([IndexFilePath filesep IndexFileName]);
tline = fgetl(FID);
while ischar(tline)
    expr = '(\d{6}\w{1}\d{2,3})'; %expression that can recognize '052311N20' or '052311N101' 
    CurrPhageName = regexpi(tline,expr,'match');
    if ~isempty(CurrPhageName)
        Index(end+1).PhageName = CurrPhageName{1};
        %now find the value of the offset
        ExprOffset = '+\s?(\d{1,3}\.\d{1,3})'; %to match the offset in '021912N10	+3.84'
        Offset = regexpi(tline,ExprOffset,'match');
        if ~isempty(Offset)
            disp(['Offset of ' Offset{1} 's found for ' CurrPhageName{1}]);
            Offset = str2num(Offset{1}(2:end)); %do not include the '+' character
        else
            disp(['No offset found for ' CurrPhageName{1}]);
            Offset = 0; %in case no offset was specified
        end
        Index(end).TimeOffset = Offset;
    else 
        CurrTimeInterval = sscanf(tline,'%f-%f'); %look for two numbers separated by a dash
        if length(CurrTimeInterval)==2
            Index(end).StartTime(end+1)  = CurrTimeInterval(1);
            Index(end).FinishTime(end+1) = CurrTimeInterval(2);
        end
    end
    tline = fgetl(FID);
end
Index(1)=[]; %the first element is empty anyway

%%
PausingEvent.PhageName   = [];
PausingEvent.PhageFile   = [];
PausingEvent.Time        = [];
PausingEvent.Contour     = [];
PausingEvent.KernelGrid  = [];
PausingEvent.KernelValue = [];
PausingEvent.LocalMaxia  = [];
i=0; %pausing event counter, useful for the plot

% load the phage data file and plot each individual pausing event
for ph = 1:length(Index) %ph is the phage Index
    CurrFile = [analysisPath filesep 'phage' Index(ph).PhageName '.mat'];
    if exist(CurrFile,'file')
        load(CurrFile); %all the data is in the structure 'stepdata'
        for pe = 1:length(Index(ph).StartTime) %pe is the pausing event index in the current phage trace
            StartTime  = (Index(ph).StartTime(pe)+Index(ph).TimeOffset);
            FinishTime = (Index(ph).FinishTime(pe)+Index(ph).TimeOffset);
            for fc = 1:length(stepdata.time) %fc is the index for feedback cycle
                if min(stepdata.time{fc})<StartTime && max(stepdata.time{fc})>FinishTime
                    Time    = stepdata.time{fc};
                    Contour = stepdata.contour{fc};
                    IndKeep = Time>=StartTime & Time<=FinishTime;
                    if sum(IndKeep)>2 %if there are any points in this selection
                        PausingEvent(end+1).PhageName = Index(ph).PhageName;
                        PausingEvent(end).PhageFile  = CurrFile;
                        PausingEvent(end).Time    = Time(IndKeep);
                        PausingEvent(end).Contour = Contour(IndKeep);
                        [PausingEvent(end).KernelGrid PausingEvent(end).KernelValue] = Adaptive_CalculateKernelDensity(PausingEvent(end).Contour,FilterFactor);
                        i=i+1; %increment the pausing event counter
                        %>>> Plot the kernel density Plot
                        figure('Units','normalized','Position',[0.01+i*0.01 0.34 0.51 0.55]); 
                        PlotAxis   = axes('Units','normalized','Position',[0.1207 0.1100 0.5313 0.8150],'Box','on'); hold on;
                        KernelAxis = axes('Units','normalized','Position',[0.6591 0.1100 0.3310 0.8150],'Box','on'); hold on;
                        %>>>>>>>>>>>>>>>>>
                        axes(PlotAxis);
                        plot(PausingEvent(end).Time,PausingEvent(end).Contour,'Color',0.8*[1 1 1]);
                        x = Adaptive_FilterAndDecimate(PausingEvent(end).Time,    FilterFactor);
                        y = Adaptive_FilterAndDecimate(PausingEvent(end).Contour, FilterFactor);
                        plot(x,y,'k');
                        set(gca,'YLim',[min(y)-range(y) max(y)+range(y)]);
                        set(gca,'XLim',[min(x)-0.05*range(x) max(x)+0.2*range(x)]);
                        xlabel('Time (s)'); ylabel('DNA Contour Length (bp)');
                        title([PausingEvent(end).PhageName]);
                        %>>>>>>>>>>>>>>>>
                        axes(KernelAxis); set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
                        plot(-PausingEvent(end).KernelValue,PausingEvent(end).KernelGrid,'b');
                        LocalMaxima = Adaptive_IdentifyLocalMaxima(PausingEvent(end).KernelGrid,PausingEvent(end).KernelValue,PeakThr);
                        PausingEvent(end).LocalMaxima = LocalMaxima;
                        ValidInd = LocalMaxima.LocalMaxInd(logical(LocalMaxima.IsValid));
                        x = PausingEvent(end).KernelGrid(ValidInd);
                        y = PausingEvent(end).KernelValue(ValidInd);
                        plot(-y,x,'.r');
                        set(KernelAxis,'YLim',get(PlotAxis,'YLim'));
                        set(KernelAxis,'XLim',[-1.1 0]);
                        for j=1:length(x) %plot dash lines
                            plot(get(gca,'XLim'),x(j)*[1 1],':m');
                        end
                        axes(PlotAxis);
                        for j=1:length(x) %plot dash lines
                            XLim=get(gca,'XLim');
                            plot(XLim,x(j)*[1 1],':m');
                            Value = sprintf('%5.1f bp',x(j));
                            text(double(XLim(2)-0.15*range(XLim)),double(x(j)+5),Value);
                        end
                    end
                end
            end
        end
    end
end

PausingEvent(1)=[]; %this element is empty anyway

end