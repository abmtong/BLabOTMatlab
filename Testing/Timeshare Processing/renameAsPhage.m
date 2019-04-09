function renameAsPhage()

[p, f] = uigetfile('*.mat', 'MultiSelect', 'on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end

len = length(f);

for i = 1:len
    stepdata= load([p f{i}]);
    fns = fieldnames(stepdata);
    %regardless of what the thing is called, 
    stepdata = stepdata.(fns{1});
    