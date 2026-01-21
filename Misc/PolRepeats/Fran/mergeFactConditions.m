function out = mergeFactConditions(ina, inb)
%Concatenates procFran structs

len = length(ina);
fns = fieldnames(ina);

%Just take data, then rerun p3
keepfn = {'nam' 'raw' 'drA' 'frc'};

out = [];
for i = 1:len
    for j = 1:length(fns)
        if any(strcmp(fns{j}, keepfn))
            out(i).(fns{j}) = [ina(i).(fns{j}) inb(i).(fns{j})];
        end
    end
end