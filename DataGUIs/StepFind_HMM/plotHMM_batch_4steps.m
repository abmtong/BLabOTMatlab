function plotHMM_batch_4steps(itermax)

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

for i = 1:length(f)
    plotHMM_4steps([p f{i}], itermax);
end