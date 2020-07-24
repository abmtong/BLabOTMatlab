function [CandidateDwells DwellLocations] = Adaptive_ValidateDwells_FragDwellInd_Consolidate_Merge2Dwells(CandidateDwells,Ind)
% merge two dwells if they are consecutive
%
% Gheorghe Chistol, 15 Nov 2012
    Ind = sort(Ind); %to make sure they are in ascending order
    if range(Ind)==1%they are consecutive, so can be merged
        NumPts1 = CandidateDwells(Ind(1)).Finish-CandidateDwells(Ind(1)).Start+1;
        NumPts2 = CandidateDwells(Ind(2)).Finish-CandidateDwells(Ind(2)).Start+1;
        Mean1   = CandidateDwells(Ind(1)).DwellLocation;
        Mean2   = CandidateDwells(Ind(2)).DwellLocation;
        CandidateDwells(Ind(1)).Mean          = (Mean1*NumPts1+Mean2*NumPts2)/(NumPts1+NumPts2);
        CandidateDwells(Ind(1)).DwellLocation = (Mean1*NumPts1+Mean2*NumPts2)/(NumPts1+NumPts2);
        CandidateDwells(Ind(1)).Finish        = CandidateDwells(Ind(2)).Finish;
        CandidateDwells(Ind(1)).FinishTime    = CandidateDwells(Ind(2)).FinishTime; %start time remains unmodifies
        CandidateDwells(Ind(2))               = []; %get rid of the second dwell at the end
    end
    
    %generated the list of updated dwell locations;
    for cd = 1:length(CandidateDwells)
        DwellLocations(cd) = CandidateDwells(cd).Mean;  
    end
end