function ParsePhageTraces_Batch_HydrodynamicCorrection()
% This function parses several Phi29 packaging traces at once in batch
% mode. It loads the raw data, substracts the corresponding offset, applies
% the appropriate calibration and saves the results. except that it can
% batch-process several files at once. It requires a BatchList file with
% instructions on how to do everything. The BatchList looks like this:
%
% 081110N07     offset081110N03     cal081110N05
% 081110N09     offset081110N04     avCal
% ...
%
% 081110N07         is the raw data file (*.dat extension, in the RawData folder)
% offset081110N03   is the offset file   (*.mat extension, in the Analysis folder)
% cal081110N05      is the calibr file   (*.mat extension, in the Analysis folder)
%
% This script applies the hydrodynamic correction for stiffness
% k(V) = k0*(1-exp(-(V-V0)/DV))
% k0 stiffness at 10V trap position
% V0 is the horizontal distance between traps, i.e. 1.34V here
% DV is 0.71V, specific decay distance (in volts) for the hydrodynamic effect
%
% USE: ParsePhageTraces_Batch_HydrodynamicCorrection()
%
% Gheorghe Chistol, 06 Jan 2013

global rawDataPath analysisPath;

%% Define default parameters and ask for dialog
Prompts = {'fsamp (Hz)','Trap X Conversion (nm/V)', ...
           'Trap Y Conversion (nm/V)','Trap X Offset (V)','Trap Y Offset (V)'};
DefaultParams = {'2500','762','578','1.34','0.45'}; % Ghe, Valid after 05/03/10
%DefaultParams = {'2500','748','565','0.54','1.08'}; % Ghe, Valid for July 31st 2009 - March 22nd 2010
InputParams = ParsePhageTraces_InputParamDialog('Enter parameters:',Prompts,DefaultParams);

Params.fsamp        = InputParams(1);
Params.TrapXconv    = InputParams(2);
Params.TrapYconv    = InputParams(3);
Params.TrapXoffset  = InputParams(4);
Params.TrapYoffset  = InputParams(5);
Params.PersLength   = 30; %DNA persistence length in nm
Params.StrModulus   = 1200; %DNA stretch modulus, in pN
Params.KbT          = 4.14; %boltzmann const, in pN*nm
Params.Threshhold   = 0.02;
%Params.StartShift   = 100; %apparently we are not using this
%Params.EndShift     = 100;
Params.FilterWindow = 100; 

%% Load the BatchList file and read its contents.
[BatchFile, BatchFilePath]       = uigetfile([analysisPath filesep '*.txt'],'MultiSelect', 'off','Select Batch File'); % the BatchList file is in the AnalysisFolder
[RawFile, OffsetFile, CalibFile] = textread([BatchFilePath filesep BatchFile], '%s %s %s'); % Read the contents of the batch file 
% all the readouts are cells
% RawFile       has a *.dat extension
% OffsetFile    has a *.mat extension
% CalibFile     has a *.mat extension
% Now check that all these files exist 
for f=1:length(RawFile) %'f' stands for 'file index'
    % Put together the full file path with the extension
    RawFile{f}    = [RawFile{f}    '.dat'];
    OffsetFile{f} = [OffsetFile{f} '.mat'];
    CalibFile{f}  = [CalibFile{f}  '.mat'];
    
    %if either of these files doesn't exist, notify user, abort execution
    if     ~exist([rawDataPath  filesep RawFile{f}],    'file')
            error(['ParsePhageTraces: ' RawFile{f}      ' is missing']);
    elseif ~exist([analysisPath filesep OffsetFile{f}], 'file')
            error(['ParsePhageTraces: ' OffsetFile{f}   ' is missing']);
    elseif ~exist([analysisPath filesep CalibFile{f}],  'file')
            error(['ParsePhageTraces: ' CalibFile{f}    ' is missing']);
    end
end

%% If everything is OK and all files exist, parse & save files one by one
for f=1:length(RawFile)
    display(['Parsing file: ' RawFile{f}]);
    StartTime   = tic;
    Files.RawFileName    = RawFile{f};
    Files.RawFilePath    = rawDataPath;
    Files.CalibFileName  = CalibFile{f};
    Files.CalibFilePath  = analysisPath;
    Files.OffsetFileName = OffsetFile{f};
    Files.OffsetFilePath = analysisPath;
    
    stepdata = ParsePhageTraces_ProcessOneFile_HydrodynamicCorrection(Files,Params);
    save([analysisPath filesep 'phage' RawFile{f}(1:end-4) '.mat'], 'stepdata'); %saves automagically, no need for extra mouse clicks
    ElapsedTime = toc(StartTime);
    disp(['It took ' num2str(ElapsedTime) 'sec to parse this trace.']);
    disp('--------------------------------------------------------------');
end