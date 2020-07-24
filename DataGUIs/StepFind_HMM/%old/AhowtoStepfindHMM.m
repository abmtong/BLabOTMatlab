% howto stepfind HMM
% 1. crop traces with @PhageGUIcrop_V2
PhageGUIcrop_V2
% 2. extract FCs into pHMM files using extractFCsHMM
extractFCsHMM; %select phage files, choose output folder
% 3. Stepfind with batchHMMV4
addpath('..\StepFind_KV') %HMM needs @windowFilter and @estimateNoise
batchHMMV4 %choose pHMM files in output folder specified in (2)
% 4. View data with plotHMM(1) or sumHMM(1)
sumHMM(1); %select pHMM files
plotHMM_batch(1); %select pHMM files
