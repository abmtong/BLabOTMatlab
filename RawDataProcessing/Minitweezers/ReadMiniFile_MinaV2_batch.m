function ReadMiniFile_MinaV2_batch()

[f, p] = uigetfile('*.txt', 'MultiSelect', 'on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end

for i = 1:length(f)
    ReadMiniFile_minaV2([p f{i}]);
end