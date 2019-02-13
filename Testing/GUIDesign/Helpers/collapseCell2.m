function outArray = collapseCell2(inCell, maxSteps)
%Collapses a cell of cells [...] of vectors into a single vector of numbers. It does so recursively.
%old2: Removes the first and last element of each vector
%2: Ignores numsteps > maxSteps
outArray = [];
if iscell(inCell)
    for i = 1:length(inCell)
        outArray = [outArray collapseCell2(inCell{i}, maxSteps)]; %#ok<AGROW>
    end
else
    if length(inCell) > maxSteps % 2
        return
        %First/last dwell is definitely wrong
        %First/last burst is probably ok
        outArray = inCell(2:end-1);
    else
        outArray = inCell;
    end
end