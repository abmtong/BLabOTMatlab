function out = mergeStructs(varargin)
%Merge N structs.
% Need a function since Matlab wants matching fieldnames

%input: structs to merge, as (struct1, struct2, ...)
in = varargin;

%Get fieldnames
fn = cellfun(@(x) fieldnames(x)', in, 'Un', 0);


%Merge fieldnames
fns = [fn{:}];

%Determine unique set of fields
ufn = unique(fns);

%Create empty fields that aren't shared. Do this stupid-like
%For every fieldname...
for i = 1:length(ufn)
    %and every input...
    for j = 1:length(in)
        %check if this fieldname is in this field...
        if ~any( strcmp( fn{j} , ufn{i} ) )
            %and if it isn't, add it
            [in{j}.(ufn{i})] = deal([]);
        end
    end
end

out = [in{:}];