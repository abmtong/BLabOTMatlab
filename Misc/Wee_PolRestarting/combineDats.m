%Gets all structs named dat* and combines them together
z = whos('dat*');
z = {z.name};

for i = 1:length(z)
    tmp = eval(z{i}); %Copy to tmp
    %Check if it's data [and not a string, e.g.]
    if isstruct(tmp)
%         alldat.(z{i}) = [alldat tmp]; %Combine
        % Alternatively maybe make a struct instead:
        alldat.(z{i}) = tmp;
    end
end