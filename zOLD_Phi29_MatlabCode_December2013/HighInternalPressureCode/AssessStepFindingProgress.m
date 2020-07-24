function Progress = AssessStepFindingProgress(OldDwells,NewDwells)
% This function compares the dwells found in two consecutive rounds of
% analysis and decides whether there has been any progress. If the dwells
% are indeed different, there has been progress and the function outputs '1'.
% If there has been no progress, the function outputs '0'.
%
% USE: Progress = AssessStepFindingProgress(OldDwells,NewDwells)
%
% Gheorghe Chistol, 25 Oct 2010
Progress=0; %start with the assumption that progress hasn't been made
for i=1:length(NewDwells.start)
    if length(OldDwells.start)>=i
        if OldDwells.start(i)>NewDwells.start(i)+2 || OldDwells.start(i)<NewDwells.start(i)-2
            Progress=1; %the dwells are no longer the same, so progress has been made
        end
    end
end