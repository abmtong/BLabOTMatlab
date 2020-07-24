function out = getNoises()

[f, p] = uigetfile('E:\011718\Phage*.mat', 'MultiSelect', 'on');
if ~iscell(f)
    f = {f};
end
len = length(f);
out = cell(len, 2);
for i = 1:len
    file = f{i};
    load([p file])
    out(i,:) = {file, estimateNoise(stepdata.force{1})};
end