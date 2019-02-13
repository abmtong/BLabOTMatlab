function out = findEnzyme(list, name)
out = [];
for i = 1:length(list)
    ind = regexp(list{i},name);
    if ind
        out = i;
        return
    end
end
