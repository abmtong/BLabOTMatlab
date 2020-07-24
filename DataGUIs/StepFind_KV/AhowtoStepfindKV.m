% howto stepfind KV
% 1. crop traces with @PhageGUIcrop_V2
PhageGUIcrop_V2
% 2. extract FCs into the workspace with @Iterate_GatherFCs, found in StepFind_Hist folder
traces = Iterate_GatherFCs; %select phage files
% 3. Filter with windowFilter
width = []; %filter width, blank to use the same as decimation factor
decimate = 5; %decimation factor, same as used in PhageGUIcrop
tracesfiltd = cellfun(@(x)windowFilter(@mean, x, width, decimate), traces, 'uni', 0);
% 4. Stepfind with BatchKV
penaltyfactor = 5;
[~, ~, ~, steps] = BatchKV(tracesfiltd, single(penaltyfactor));
%the steps will be stored in the variable, and you will see an output window pop up