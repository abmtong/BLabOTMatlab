% Add basic paths
startupbasepath = fileparts(mfilename('fullpath')); %C:\... \MATLAB\
startupfolders = {'Phi29_Alex' 'Phi29_Alex\helperFunctions' 'Phi29_Alex\Calibration' 'Testing\GUIDesign' 'Testing\GUIDesign\StepFind_KV' 'Testing\GUIDesign\StepFind_HMM' 'Testing\GUIDesign\Velocity'};
cellfun(@(x)addpath([startupbasepath filesep x]), startupfolders);
clear startupbasepath startupfolders