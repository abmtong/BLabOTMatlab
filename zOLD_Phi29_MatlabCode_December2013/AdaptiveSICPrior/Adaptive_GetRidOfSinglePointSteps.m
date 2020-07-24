function DwellInd = Adaptive_GetRidOfSinglePointSteps(DwellInd)
% If there is a dwell that consists of a single point, get rid of it and merge into the nearest
% dwell. At this point the DwellInd structure has only three fields
% DwellInd(d).Start
% DwellInd(d).Finish
% DwellInd(d).Mean
%
% USE: DwellInd = Adaptive_GetRidOfSinglePointSteps(DwellInd)
%
% Gheorghe Chistol, 10 Nov 2012

    d=1;
    while d<=length(DwellInd)
        if (DwellInd(d).Finish - DwellInd(d).Start) == 1
            disp('     ! Getting rid of a single-point dwell');
            %if d==1 merge into d=2
            %if d==end, merge into d=end-1
            %if neither, merge into the nearest neighbor
            if d>1 && d<length(DwellInd)
                PrevDwellMean = DwellInd(d-1).Mean;
                CurrDwellMean = DwellInd(d).Mean;
                NextDwellMean = DwellInd(d+1).Mean;
                if abs(CurrDwellMean-PrevDwellMean) < abs(CurrDwellMean-NextDwellMean)
                    m=d-1; %merge with (d-1)th dwell
                else
                    m=d+1; %merge with (d-1)th dwell
                end
            elseif d==1
                m=d+1; %merge only with the next dwell
            else %d==end, i.e. the very last dwell
                m=d-1; %merge only with the previous dwell
            end
            NumPtsD = DwellInd(d).Finish-DwellInd(d).Start+1;
            NumPtsM = DwellInd(m).Finish-DwellInd(m).Start+1;
            DwellInd(m).Mean   = (DwellInd(m).Mean*NumPtsM+DwellInd(d).Mean*NumPtsD)/(NumPtsD+NumPtsM);
            DwellInd(m).Start  = min([DwellInd(d).Start DwellInd(d).Finish DwellInd(m).Start DwellInd(m).Finish]);
            DwellInd(m).Finish = max([DwellInd(d).Start DwellInd(d).Finish DwellInd(m).Start DwellInd(m).Finish]);
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