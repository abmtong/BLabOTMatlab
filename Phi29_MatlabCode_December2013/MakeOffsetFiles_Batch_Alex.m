function MakeOffsetFiles_Batch_Alex(analysisFilePath,Params)
% This function generates offset files based on the BatchFile recipe. All
% you need is a batch file, which will later be used by ParsePhageTraces()
% to batch process several phages. The current function will read the batch
% file and process only the neccessary offset files, then save them
%
% USE: MakeOffsetFiles_Batch()
%
% Gheorghe Chistol, 09 Deb 2012

global rawDataPath analysisPath; % Declare the RawDataPath and AnalysisPath 

%% Pop up a dialog box for defining parameters
%{
Prompts       = {'Nano-MTA2 Step Threshold (V)',...
                 'Filter Window Size (Points)',...
                 'Front Pad (Points)',...
                 'Sampling Frequency (Hz)',...
                 'Direction (X=1; Y=0)'};
DefaultParams = {'1e-5','50','60', '2500', '1'};
InputParams   = MakeOffsetFiles_InputParamDialog('Parameters for Processing Offsets',Prompts,DefaultParams);
%}

%Use default values if Params is not passed
if nargin <2;
    Params.vThreshold = 1e-5;
    Params.nWindow    = 50; 
    Params.frontPad   = 60;
    Params.fSample    = 2500; 
    Params.sDirection = 1;
end
%% Load Batch File and Read its Contents
%Use the supplied file if given, else prompt the user
if(nargin<1);
    %get the batch file from analysis folder
    [BatchFile,BatchFilePath] = uigetfile([analysisPath filesep '*.txt'],'MultiSelect','off','Select Batch File'); 
    analysisFilePath = [BatchFilePath filesep BatchFile];
end

% Read the contents of the batch file
[~, OffsetFiles, ~] = textread(analysisFilePath, '%s %s %s');
% OffsetFile    has a *.mat extension

% Now check that all these files exist 
OffsetFiles    = unique(OffsetFiles); %many offset files may be used multiple times, process them only once
RawOffsetFiles = cell(1,length(OffsetFiles)); %initialize a cell

for f = 1:length(OffsetFiles)
    % Put together the full file path with the extension
    RawOffsetFiles{f} = [OffsetFiles{f}(7:end) '.dat']; %'offset090910' gets converted to '090910'
    
    if ~exist([rawDataPath filesep RawOffsetFiles{f}],'file')
        error(['MakeOffsetFiles: missing file :( ' RawOffsetFiles{f}]); %abort if a file does not exist
    end
end

%% Load and Parse Offset Data Files One by One
for f = 1:length(RawOffsetFiles)
    offset = MakeOffsetFiles_ProcessSingleFile(Params, RawOffsetFiles{f}, rawDataPath);
    save([analysisPath filesep OffsetFiles{f} '.mat'],'offset');
    disp(['Offset data saved to ' OffsetFiles{f}]);
end