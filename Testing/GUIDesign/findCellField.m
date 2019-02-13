function outInd = findCellField(inCell, inStr)
%Looks for inStr in inCell(:,1) and returns the index or len+1 if it's not found

if isempty(inCell)
    outInd = 1;
    return;
end

%It's really fun to write @cellfun code, but it's often harder to read and slower, so fml
inds = cellfun(@(str)(strcmp(str,inStr)), inCell(:,1));
ind = find(inds>0);
if ~isempty(ind)
    if length(ind) > 1
        warning('Multiple fields with name %s, returning first one\n',inStr)
    end
    outInd = ind(1);
else
    outInd = size(inCell,1)+1;
end