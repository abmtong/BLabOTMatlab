function out = getWLCs(st)

%Get the WLC fits
fns = fieldnames(st);
len = length(fns);
out = cell(1,len);
for i = 1:len
    out{i} = st.(fns{i}).wlc;
end

%Reshape out to a table
out = [out{:}];
out = reshape([out{:}],5,[])';