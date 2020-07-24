function ConsecutivePts = AMPPNP_KV_StepFinding_FindMostConsecutivePts(Index)
% This function takes in the index of points above/below the mean of a
% dwell, for example [1 1 0 0 0 1 0 1 0 1 1 1 0 0 0 0], and determines how
% many consecutive points there are (the most consecutive points in any
% portion)
%
% USE: ConsecutivePts = AMPPNP_KV_StepFinding_FindMostConsecutivePts(Index)
%
% Gheorghe Chistol, 16 May 2011

ConsecutivePts = 0;
CurrIsland = 0; %island of consecutive pts

for i=1:length(Index)
    if Index(i)==1 %we got one point
        %this is the continuation of an existing island or a new island
        CurrIsland = CurrIsland+1;
    else %we got no point
        if CurrIsland>0 % we just ended an island
            if CurrIsland>ConsecutivePts %the current island is larger than the previous largest island
                ConsecutivePts=CurrIsland;
            end
            CurrIsland = 0; %reset the count, the island just ended
        end
    end
end

