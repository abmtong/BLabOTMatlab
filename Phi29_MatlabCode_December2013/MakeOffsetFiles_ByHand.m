function MakeOffsetFiles_ByHand()
% While 'MakeOffsetFiles.m' is highly automated and requires a script with
% the list of offset files to be made, this function allows the user to
% just select a list of raw files containing offset data and save the
% corresponding offset*.mat files (old school :).
%
% USE: MakeOffsetFiles_ByHand()
%
% Gheorghe Chistol, 10 Feb 2012

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

    %% Select the Raw Files
    [RawOffsetFile, RawOffsetFilePath] = uigetfile([rawDataPath filesep '*N*.dat'],'MultiSelect','on','Select Raw Offset File(s)'); 

    if ~iscell(RawOffsetFile)
        temp = RawOffsetFile; RawOffsetFile = ''; RawOffsetFile{1}=temp; 
    end

    %% Load and Parse Offset Data Files One by One
    for f = 1:length(RawOffsetFile)
        offset = MakeOffsetFiles_ProcessSingleFile(Params, RawOffsetFile{f}, RawOffsetFilePath);
        save([analysisPath filesep 'offset' RawOffsetFile{f}(1:end-4) '.mat'],'offset');
        disp(['Offset data saved to ' ['offset' RawOffsetFile{f}(1:end-4) '.mat']]);
    end
end