function [StepSize DwellTime DwellLocation DwellStd DwellStErr SteppingFileName]=BurstAlignment_LoadSteppingFile()
% This function works in tandem with other functions of the BurstAlignment
% family. It loads a text file that contains the stepping data.
%
% USE: [StepSize DwellTime DwellLocation DwellStd DwellStErr SteppingFileName]=BurstAlignment_LoadSteppingFile()
%
% Gheorghe Chistol, 28 Dec 2010

global analysisPath; % Set the Analysis Path
if isempty(analysisPath)
    disp('analysisPath not defined. Use "SetAnalysisPath" to define it'); return;
end

% Use the GUI to select the Stepping File
SteppingFileName = uigetfile([ [analysisPath '\ExportSteps\'] '*.steps'], 'Please select one Stepping File','MultiSelect', 'off');
SteppingFile = [analysisPath '\ExportSteps\' SteppingFileName];
if ~exist(SteppingFile) %if no files were selected or file doesn't exist
    disp('No Stepping File was selected'); return;
end

StepSize      = [];  
DwellStd      = [];  
DwellStErr    = [];  
DwellTime     = [];  
DwellLocation = []; 

%----- Read the stepping pattern from the text file
fid = fopen(SteppingFile);
tline = fgetl(fid); %take the header line off
tline = fgetl(fid); %get the first sata line
while ischar(tline)
    temp                 = sscanf(tline,'%f'); %read the current line #ok<*AGROW>
    StepSize(end+1)      = temp(1);
    DwellStd(end+1)      = temp(2);
    DwellStErr(end+1)    = temp(3);
    DwellTime(end+1)     = temp(4);
    DwellLocation(end+1) = temp(5); 
    tline                = fgetl(fid); %get the next line
end
fclose(fid);