function out = plotHMM_batch(itermax)

if nargin < 1
    itermax = inf;
end

[f,p] = uigetfile('E:\dsRNA - HMM\HMM', 'MultiSelect', 'on');
if ~p
    return
end

if ~iscell(f)
    f = {f};
end

out = cell(size(f));
for i = 1:length(f)
    out{i} = plotHMM([p f{i}], itermax);
end