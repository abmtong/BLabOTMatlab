% Add basic paths
startupbasepath = 'C:\Users\Alexander Tong\Box Sync\Res\MATLAB\';
startupfolders = {'Phi29_Alex' 'Phi29_Alex\helperFunctions' 'Phi29_Alex\Calibration' 'Testing\GUIDesign' 'Testing\GUIDesign\StepFind_KV' 'Testing\GUIDesign\StepFind_HMM'};
cellfun(@(x)addpath([startupbasepath x]), startupfolders);
clear startupbasepath startupfolders