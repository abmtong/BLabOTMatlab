function out = addStructs(st)
%Turns a 1xn struct to a scalar struct
%i.e., out(fn) = [st.(fn)];
% For fields that that doesn't work, replace with empty

fns = fieldnames(st);

for i = 1:length(fns)
    try
        out.(fns{i}) = [st.(fns{i})];
    catch
        out.(fns{i}) = [];
    end
end
