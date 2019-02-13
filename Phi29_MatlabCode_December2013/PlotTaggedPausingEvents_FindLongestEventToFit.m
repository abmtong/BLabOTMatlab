function pe = PlotTaggedPausingEvents_FindLongestEventToFit(PausingEvent,TimeLeft)
%what is the index of the longest possible pausing event that still fits in the TimeLeft window
% PausingEvent(i).PhageName
% PausingEvent(i).PhageFile
% PausingEvent(i).Time
% PausingEvent(i).Contour
% PausingEvent(i).Span
% PausingEvent(i).Duration
pe = 1;

for pe=1:length(PausingEvent)
    if PausingEvent(pe).Duration < TimeLeft
        return; %we found what we were looking for
    end
end

pe = []; %if we haven't found anything, return empty index