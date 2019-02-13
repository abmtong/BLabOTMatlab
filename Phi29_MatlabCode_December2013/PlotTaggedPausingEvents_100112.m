% We have a list of tagged pausing events in a text file that looks like this
% 052311N83
% 	17.4-22.5
% 052311N80
% 	11.6-16.4
% 	27.4-28.0
% 052311N75 
% 	101-102.6
% 	106.1-106.7
% 	118.8-136.1
%
% It contains the trace name and the StartTime-FinishTime in seconds

FilterFactor = 25; %how to prefilter the data before plotting

global analysisPath;

%% Load PauseIndex file and Parse the file to compile an index of pausing events
[IndexFileName IndexFilePath] = uigetfile([analysisPath filesep '*.txt'],'MultiSelect','off');
clear Index;
Index.PhageName = [];
Index.StartTime = [];
Index.FinishTime = [];

FID = fopen([IndexFilePath filesep IndexFileName]);
tline = fgetl(FID);
while ischar(tline)
    expr = '(\d{6}\w{1}\d{2,3})'; %expression that can recognize '052311N20' or '052311N101' 
    CurrPhageName = regexpi(tline,expr,'match');
    if ~isempty(CurrPhageName)
        Index(end+1).PhageName = CurrPhageName{1};
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
PausingEvent.PhageName = [];
PausingEvent.PhageFile = [];
PausingEvent.Time      = [];
PausingEvent.Contour   = [];
PausingEvent.Duration  = [];
PausingEvent.Span      = [];
% load the phage data file and plot each individual pausing event
for ph = 1:length(Index) %ph is the phage Index
    CurrFile = [analysisPath filesep 'phage' Index(ph).PhageName '.mat'];
    if exist(CurrFile,'file')
        load(CurrFile); CurrData = stepdata; clear stepdata;
        Time = []; Contour = [];
        for fc = 1:length(CurrData.time) %fc is the index for feedback cycle
            Time    = [Time    FilterAndDecimate(CurrData.time{fc},    FilterFactor)];
            Contour = [Contour FilterAndDecimate(CurrData.contour{fc}, FilterFactor)];
        end
        for pe = 1:length(Index(ph).StartTime) %pe is the pausing event index
            IndKeep = Time>=Index(ph).StartTime(pe) & Time<=Index(ph).FinishTime(pe);
            if sum(IndKeep)>2 %if there are any points in this selection
                PausingEvent(end+1).PhageName = Index(ph).PhageName;
                PausingEvent(end).PhageFile  = CurrFile;
                PausingEvent(end).Time    = Time(IndKeep);
                PausingEvent(end).Contour = Contour(IndKeep);
                PausingEvent(end).Span = range(PausingEvent(end).Contour);
                PausingEvent(end).Duration = range(PausingEvent(end).Time);
            end
        end
    end
end

PausingEvent(1)=[]; %this element is empty anyway

%% Sort the pausing events by duration
Duration = [];
for pe = 1:length(PausingEvent)
    Duration(pe) = PausingEvent(pe).Duration;
end
[~, SortInd] = sort(Duration,'descend');
PausingEvent = PausingEvent(SortInd); %longest events come first

PE = PausingEvent; %(make a copy that we will slowly consume)
%% Plot the pausing events
%plot the longest first
%on top of it plot the second longest and find another one that can fit in
%keep adding more pausing events until no more can fit
%then start a new row

figure; hold on;
Status = 1;
while ~isempty(PE) %do this as long as we have pausing events
    if Status==1 %if we're just starting, plot the longest event
        Status=0; 
        pe = 1;
        t = PE(pe).Time;
        c = PE(pe).Contour;
        t = t-min(t);
        c = c-min(c);
        plot(t,c,'b');
        MaxTime = range(t); %maximum width of a row of pausing events
        cOffset = range(c)+5; %this is how much the next pausing event has to be offset
        tOffset = 0; %the next row will start at zero time
        SpanList = []; %the list of pausing events span. This will be used to determine the offset when the next row is finished
        PE(pe)=[]; %delete the current pausing event since we used it
    else
        TimeLeft = MaxTime-tOffset; %this is how much horizontal space we have to plot the next event
        pe = PlotTaggedPausingEvents_FindLongestEventToFit(PE,TimeLeft); %what is the index of the longest possible pausing event that still fits in the TimeLeft window
        if ~isempty(pe) %we can fit another event in the current row
            t = PE(pe).Time; c = PE(pe).Contour;
            t = t-min(t)+tOffset;    c = c-min(c)+cOffset;
            tOffset = max(t); %update the temporal offset, no need to update cOffset yet, we might be able to fit another event in this row
            SpanList(end+1) = PE(pe).Span; %at the current event span to the spanlist of events in the current row
            PE(pe)=[]; %remove the current event, we're done using it
            plot(t,c,'b');
        else %we can't fit another event in the current row
            tOffset = 0; %start a new row
            cOffset = cOffset+max(SpanList)+5; %offset by the largest span in the last row
            SpanList = []; %the span list is now empty
        end
    end
end