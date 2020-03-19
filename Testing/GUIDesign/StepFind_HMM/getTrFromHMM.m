function out = getTrFromHMM()

[f, p] = uigetfile('pHMM*.mat', 'Mu', 'on');

if ~p
    return
end
if ~iscell(f)
    f = {f};
end

len = length(f);

for i = len:-1:1
    tmp = load(fullfile(p, f{i}));
    out(i) = tmp.fcdata;
end