function DwellInd = Adaptive_GetRidOfSinglePointSteps(DwellInd)
    d=1;
    while d<=length(DwellInd)
        if (DwellInd(d).Finish - DwellInd(d).Start) == 1
            disp('     ! Getting rid of a single-point dwell');
            DwellInd(d) = []; %no need to increment index
        elseif (DwellInd(d).Finish - DwellInd(d).Start) == 0
            disp('     ! Getting rid of a zero-point dwell');
            DwellInd(d) = []; %no need to increment
        else
            d=d+1;
        end
    end
    %    DwellInd(d).Start
    %    DwellInd(d).Finish
    %    DwellInd(d).Mean
end