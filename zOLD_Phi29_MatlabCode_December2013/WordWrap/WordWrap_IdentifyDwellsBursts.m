function ActualDwellInd = WordWrap_IdentifyDwellsBursts(DwellLocation,DwellDuration,BestBurstSize,BestGridOffset,DwellSearchRegion)
% Given the DwellLocation and DwellDuration, identify the most likely
% Dwell/Burst assignment. This requires using the word-wrap algorythm to
% find the optimal burst size and optimat grid offset.
%
% USE: ActualDwellInd = WordWrap_IdentifyDwellsBursts(DwellLocation,DwellDuration,Params)
%
% Params.BestGridOffset
% Params.BestBurstSize
% Params.DwellSearchRegion - as a fraction of burst size. Region to search
%                            for the dwell (away from the nearest grid line)
%
%
% USE: ActualDwellInd = WordWrap_IdentifyDwellsBursts(DwellLocation,DwellDuration,BestBurstSize,BestGridOffset,DwellSearchRegion)
%
% gheorghe chistol, 20 feb 2013
    

    Grid = (max(DwellLocation)+BestGridOffset):-BestBurstSize:(min(DwellLocation)-BestBurstSize);
    %now identify the dwell located within the Params.DwellSearchRegion
    %away from any grid Line
    DwellInd = [];
    for g=1:length(Grid)
        CurrGridLocation = Grid(g);
        TempDistance = abs(DwellLocation-CurrGridLocation);
        NearestInd = find(TempDistance<DwellSearchRegion*BestBurstSize);
        TempDuration = DwellDuration(NearestInd);
        LongestInd = find(TempDuration==max(TempDuration),1,'first');
        if ~isempty(NearestInd(LongestInd))
            DwellInd(end+1) = NearestInd(LongestInd);
        end
    end
    
    ActualDwellInd = unique(DwellInd);
end