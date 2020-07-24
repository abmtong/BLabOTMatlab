function MakeOffsetFiles_Batch()
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
Prompts       = {'Nano-MTA2 Step Threshold (V)',...
                 'Filter Window Size (Points)',...
                 'Front Pad (Points)',...
                 'Sampling Frequency (Hz)',...
                 'Direction (X=1; Y=0)'};
DefaultParams = {'1e-5','50','60', '2500', '1'};
InputParams   = MakeOffsetFiles_InputParamDialog('Parameters for Processing Offsets',Prompts,DefaultParams);

Params.vThreshold = InputParams(1);
Params.nWindow    = InputParams(2); 
Params.frontPad   = InputParams(3);
Params.fSample    = InputParams(4); 
Params.sDirection = InputParams(5);

%% Load Batch File and Read its Contents
%Use the supplied file if given, else prompt the user
if(nargin<1);
    %get the batch file from analysis folder
    [BatchFile,BatchFilePath] = uigetfile([analysisPath filesep '*.txt'],'MultiSelect','off','Select Batch File'); 
    % Read the contents of the batch file 
    [~, OffsetFiles, ~] = textread([BatchFilePath filesep BatchFile], '%s %s %s');
    % OffsetFile    has a *.mat extension
end
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