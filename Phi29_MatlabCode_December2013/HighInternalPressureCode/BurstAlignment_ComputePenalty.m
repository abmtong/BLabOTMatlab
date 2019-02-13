function Penalty=BurstAlignment_ComputePenalty(DwellStaircase1,DwellStaircase2,Err1,Err2,TrialBurstSize)
% Compute the penalty for the dwell pair defined by
% DwellStaircase1 & DwellStaircase2 & Err1 & Err2
%
% USE:
% Penalty=BurstAlignment_ComputePenalty(DwellStaircase1,DwellStaircase2,Err1,Err2,TrialBurstSize)
%
% Gheorghe Chistol, 17 Dec 2010

%ZeroPenaltyRegion=TestBurstSize+/-(Err1+Err2);
DwellSeparation = (DwellStaircase1-DwellStaircase2);
%Err1=0;
%Err2=0;

%Condition1 = logical(DwellSeparation<TrialBurstSize+(Err1+Err2));
%Condition2 = logical(DwellSeparation>TrialBurstSize-(Err1+Err2));

if (DwellSeparation<TrialBurstSize+(Err1+Err2)) && (DwellSeparation>TrialBurstSize-(Err1+Err2))
    %if Condition1 && Condition2
    %dwell separation is in the zero penalty regime
    Penalty=0;
%elseif DwellSeparation>TrialBurstSize*1.6
%    Penalty=2*(abs(DwellSeparation-2*TrialBurstSize)-(Err1+Err2))^2;
else
    Penalty=(abs(DwellSeparation-TrialBurstSize)-(Err1+Err2))^2;
end

