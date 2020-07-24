function ForceExt_ParseTrace_Batch_Felix()
% I modified this to generate files that Felix Ritort asked for. We are using 62.5kHz data which
% requires loading each channel from a separate file.
% Process force extension curve data (pulling on DNA, RNA hairpins,
% proteins). This particular file works with 2500Hz data files. Distances
% are measured in [nm], forces are measured in [pN]. This particular
% function asks for a 'ForceExtensionBatch*.txt' file that contains
% instructions for batch processing several force-extension files at once.
% The lines in the batch file are like this:
%
% F(x) file       Offset File        Cal File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 011112N05     offset011112N06     cal011112N07
% 011112N08     offset011112N09     cal011112N10
% ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% USE: ForceExt_ParseTrace_Batch()
%
% Gheorghe Chistol, 13 Feb 2012

    global analysisPath; global rawDataPath;

    %% Prompt for Calibration Parameters
    Prompts       = {'Sampling Frequency (Hz)',...
                     'NanoMTA2 X Scanning Calibration (nm/V)',...
                     'NanoMTA2 X Scanning Calibration (nm/V)',...
                     'NanoMTA2 X Voltage Offset (V)',...
                     'NanoMTA2 Y Voltage Offset (V)'};
    %DefaultParams = {'2500','762','578','1.34','0.45'}; % Calibration Values Ghe 28 April 2010
    DefaultParams = {'62500','733','603','0.85','0.49'}; % Calibration Values Ghe July 2009
    Params        = ForceExt_InputParamDialog('Define Parameters: ',Prompts,DefaultParams);
    fsamp         = Params(1); 
    TrapXconv     = Params(2); 
    TrapYconv     = Params(3);
    TrapXoffset   = Params(4); 
    TrapYoffset   = Params(5);

    %% Load the BatchList file and read its contents.
    % the BatchList file is in the AnalysisFolder
    [BatchFileName BatchFilePath]  = uigetfile([analysisPath filesep 'ForceExtensionBatch*.txt'],'MultiSelect','off',...
                                                                     'Please select the BatchFile');
    [RawFile, OffsetFile, CalFile] = textread([BatchFilePath filesep BatchFileName], '%s %s %s');% Read the contents of the batch file 
    % all the readouts are cells
    % RawFile       has a *.dat extension
    % OffsetFile    has a *.mat extension
    % CalibFile     has a *.mat extension
    % Now check that all these files exist 
    RawFilePath    = rawDataPath;
    OffsetFilePath = analysisPath;
    CalFilePath    = analysisPath;
    RawFileName    = cell(1,length(RawFile));
    OffsetFileName = cell(1,length(RawFile));
    CalFileName    = cell(1,length(RawFile));


    for f=1:length(RawFile)
        % Put together the full file path with the extension
        RawFileName{f}    = [RawFile{f}    '.dat'];
        OffsetFileName{f} = [OffsetFile{f} '.mat'];
        CalFileName{f}    = [CalFile{f}    '.mat'];

        %if either of these files doesn't exist, notify user, abort execution
        if ~exist([RawFilePath filesep RawFileName{f}],'file')
            error([RawFileName{f} ' is missing, task aborted']);
        elseif ~exist([OffsetFilePath filesep OffsetFileName{f}],'file')
            error([OffsetFileName{f} ' is missing, task aborted']);
        elseif ~exist([CalFilePath filesep CalFileName{f}],'file')
            error([CalFileName{f} ' is missing, task aborted']);
        end
    end

    %% Now parse Force-Extension files one by one, then save them
    for f = 1:length(RawFileName)
        Tstart = tic;
        %package the file names and paths in a convenient structure
        FileNameAndPath.RawFileName    = RawFileName{f};
        FileNameAndPath.RawFilePath    = RawFilePath;
        FileNameAndPath.OffsetFileName = OffsetFileName{f};
        FileNameAndPath.OffsetFilePath = OffsetFilePath;
        FileNameAndPath.CalFileName    = CalFileName{f};
        FileNameAndPath.CalFilePath    = CalFilePath;
        
        [ContourData CalibratedData OffsetData] = ForceExt_ParseTrace_ProcessOneFile_Felix(FileNameAndPath,Params);
        
        % Save the Processed Data to a file;
        disp(['Saving File ' 'ForceExtension_' RawFileName{f}(1:end-4) '.mat']);
        save([analysisPath filesep 'ForceExtension_' RawFileName{f}(1:end-4) '.mat'],'ContourData','CalibratedData','OffsetData');
        Tstop = toc(Tstart);
        disp(['   time elapsed: ' num2str(Tstop,'%3.2f') ' sec']);
        disp('-------------------------------------------------------------');
        
    end
end