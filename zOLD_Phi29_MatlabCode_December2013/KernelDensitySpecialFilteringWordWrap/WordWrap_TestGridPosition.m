function [BestLsqPen BestAkaikePen BestGridOffset LeastSquaresScore AkaikeScore GridOffset] = WordWrap_TestGridPosition(DwellLocation,DwellDuration,BurstSize,GridPosIncr)
% for a given burst size, find the best position of the grid (i.e. offset)
%
% USE: [BestLsqPen BestAkaikePen BestGridOffset] = WordWrap_TestGridPosition(DwellLocation,DwellDuration,BurstSize,GridPosIncr)
%
% gheorghe chistol, 19 feb 2013

    GridOffset = -0.5*BurstSize:GridPosIncr:0.5*BurstSize;
    LeastSquaresScore = nan(size(GridOffset));
    AkaikeScore       = nan(size(GridOffset));

    for g=1:length(GridOffset)
        CurrGrid = (max(DwellLocation)+GridOffset(g)+BurstSize):(-BurstSize):(min(DwellLocation)-BurstSize);
        [LeastSquaresScore(g) AkaikeScore(g)] = WordWrap_ComputePenalty(DwellLocation,DwellDuration,CurrGrid);  
    end
    
    %BestInd        = find(LeastSquaresScore==min(LeastSquaresScore),1,'first');
    BestInd        = find(AkaikeScore==min(AkaikeScore),1,'first');
    BestLsqPen     = LeastSquaresScore(BestInd);
    BestAkaikePen  = AkaikeScore(BestInd);
    BestGridOffset = GridOffset(BestInd);
    
end