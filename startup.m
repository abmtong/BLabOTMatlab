% Add basic paths
basepath = 'C:\Users\Alexander Tong\Box Sync\Year 2 Semester 2\Res\MATLAB\';
folders = {'Phi29_Alex' 'Phi29_Alex\helperFunctions' 'Phi29_Alex\Calibration' 'Testing\GUIDesign' 'Testing\GUIDesign\StepFind_KV' 'Testing\GUIDesign\StepFind_HMM' 'Testing\GUIDesign\StepFind_Hist'};
cellfun(@(x)addpath([basepath x]), folders);