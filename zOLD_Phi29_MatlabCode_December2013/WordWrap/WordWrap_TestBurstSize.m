function [BestBurstSize BestGridOffset LsqPen AkaikePen TestBurst] = WordWrap_TestBurstSize(DwellLocation,DwellDuration,MinTestBurst,MaxTestBurst,TestBurstIncr,GridOffsetIncr)
%
% USE: [BestBurstSize BestGridOffset LsqPen AkaikePen TestBurst] =
% WordWrap_TestBurstSize(DwellLocation,DwellDuration,MinTestBurst,MaxTestBurst,TestBurstIncr,GridOffsetIncr)
%
% gheorghe chistol, 19 Feb 2013
    TestBurst  = MinTestBurst:TestBurstIncr:MaxTestBurst;
    LsqPen     = nan(size(TestBurst));
    AkaikePen  = nan(size(TestBurst));
    GridOffset = nan(size(TestBurst));
    
    for b = 1:length(TestBurst)
        CurrBurstSize = TestBurst(b);
        [LsqPen(b) AkaikePen(b) GridOffset(b)] = WordWrap_TestGridPosition(DwellLocation,DwellDuration,CurrBurstSize,GridOffsetIncr);
    end
    BestInd        = find(AkaikePen == min(AkaikePen),1,'first');
    BestBurstSize  = TestBurst(BestInd);
    BestGridOffset = GridOffset(BestInd);
    
end