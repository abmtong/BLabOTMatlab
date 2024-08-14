function out = addStructOmar(inst)

%Adds structs together, simply by concatenation

fns = fieldnames(inst);

for i = 1:length(fns)
    %Try to horzcat
    try
        out.(fns{i}) = [inst.(fns{i})];
    catch
        %Else just replace with empty
        out.(fns{i}) = [];
    end
end