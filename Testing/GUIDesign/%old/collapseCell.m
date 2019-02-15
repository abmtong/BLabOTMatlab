function outArray = collapseCell(inCell)
%Collapses a cell of cells [...] of vectors into a single vector of numbers. It does so recursively, so can handle different "cell depths" (as opposed to doing [inCell{:}])
outArray = [];
if iscell(inCell)
    for i = 1:length(inCell)
        outArray = [outArray collapseCell(inCell{i})]; %#ok<AGROW>
    end
else
    outArray = inCell;
end