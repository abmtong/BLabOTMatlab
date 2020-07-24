function ATPBindingDwells = BurstSize__Main_GUI_SortATPBindingDwells(Dwells,ATPDwellInd)
% Once you do the WordWrap method, and identify the ATP binding dwells,
% sort things out and organize the data by Dwell and Burst. We are interested in DwellDuration and BurstDuration 
% 
% >> Dwells
%            StartTime: [1x17 double]
%           FinishTime: [1x17 double]
%        DwellDuration: [1x17 double]
%        DwellLocation: [1x17 double]
%     DwellLocationErr: [1x17 single]
%           DwellForce: [1x17 single]
%       SizeStepBefore: [1x17 double]
%        SizeStepAfter: [1x17 double]
%        StaircaseTime: [1x34 double]
%     StaircaseContour: [1x34 double]
%
% USE: ATPBindingDwells = BurstSize__Main_GUI_SortATPBindingDwells(Dwells,ATPDwellInd)
%
% Gheorghe Chistol, 22 Feb 2013

    %organize the dwell data
    for i = 1:length(ATPDwellInd)
        cd = ATPDwellInd(i);   %current ATP-binding-dwell index        
        ATPBindingDwells.Dwell.StartTime(i)    = Dwells.StartTime(cd);
        ATPBindingDwells.Dwell.FinishTime(i)   = Dwells.FinishTime(cd);
        ATPBindingDwells.Dwell.Duration(i)     = Dwells.DwellDuration(cd);
        ATPBindingDwells.Dwell.MeanLocation(i) = Dwells.DwellLocation(cd);
        ATPBindingDwells.Dwell.MeanForce(i)    = Dwells.DwellForce(cd);
    end
    
    %organize the burst data
    for b = 1:(length(ATPDwellInd)-1) %b is the index of the burst
        pd = ATPDwellInd(b);   %previous ATP-binding-dwell index
        nd = ATPDwellInd(b+1); %next ATP-binding-dwell index
    
        ATPBindingDwells.Burst.StartTime(b)    = Dwells.FinishTime(pd);
        ATPBindingDwells.Burst.FinishTime(b)   = Dwells.StartTime(nd);
        ATPBindingDwells.Burst.Duration(b)     = ATPBindingDwells.Burst.FinishTime(b)-ATPBindingDwells.Burst.StartTime(b);
        ATPBindingDwells.Burst.MeanLocation(b) = (ATPBindingDwells.Dwell.MeanLocation(b)+ATPBindingDwells.Dwell.MeanLocation(b+1))/2;
        ATPBindingDwells.Burst.MeanForce(b)    = (ATPBindingDwells.Dwell.MeanForce(b)+ATPBindingDwells.Dwell.MeanForce(b+1))/2;
    end
end
