function [LsqPenaltyPerBurst AkaikeScore] = WordWrap_ComputePenalty(DwellLocation,DwellDuration,Grid)
% Given the contour data (duration and location) and a grid, compute the
% least square difference between the grid and the data. 
% LsqPenaltyPerBurst is calculated by dividing the LeastSquareScore by # of bursts
% AkaikeScore is calculated too
%
% USE: [LeastSquaresScore AkaikeScore] = WordWrap_ComputePenalty(DwellLocation,DwellDuration,Grid)
%
% gheorghe chistol, 19 Feb 2013

    LeastSquaresScore = 0;
    UsedIndex = nan(size(DwellLocation));
    for d=1:length(DwellLocation)
        Temp = abs(Grid-DwellLocation(d));
        Ind = find(Temp==min(Temp),1,'first');
        NearestGrid = Grid(Ind);
        LeastSquaresScore = LeastSquaresScore+DwellDuration(d)*(DwellLocation(d)-NearestGrid)^2;
        UsedIndex(d)=Ind;
    end
    UsedIndex = unique(UsedIndex); %what gridlines were used for this calculation
                                   %useful for Akaike score
    k = length(UsedIndex); %number of gridlines used
    LsqPenaltyPerBurst = LeastSquaresScore/k; %per burst
    AkaikeScore = 2*k*(1+log(LeastSquaresScore)); %to prevent overfitting
    
end