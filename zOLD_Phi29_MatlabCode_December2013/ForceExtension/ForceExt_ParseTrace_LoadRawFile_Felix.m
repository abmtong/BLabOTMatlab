function data = ForceExt_ParseTrace_LoadRawFile_Felix(fsamp,RawFileName,RawFilePath)
% Reads binary data file, and outputs to structure "data". I modified
% Jeff's original file to be able to read extremely large files (300+Mb).
% This is done via memmapfile, which maps the file without loading it,
% enabling you to access it as if it were a matrix, indexing only the stuff
% you care about.
% 
% USE: data = ForceExt_ParseTrace_LoadRawFile(fsamp,RawFileName,RawFilePath)
%
% Gheorghe Chistol, 09 Feb 2012 

    data.path = RawFilePath;
    data.file = RawFileName;
    data.date = date;
    
    HighFreqFile = RawFileName;
    FilePath     = RawFilePath;

    % letter = {'' 'a' 'b' 'c' 'd' 'e' 'f' 'g'}; %high-freq data is a set of 8 files, each one of them contains recordings for one particular voltage
    header = 85; %the files have a header that has to be removed
    fprintf(['------ Loading ' HighFreqFile ': ']);
    %% Read Sum Voltage A, from file 'f'
    FileHandle = fopen([FilePath filesep 'f' HighFreqFile]);
    temp       = fread(FileHandle,1e10,'float32','ieee-be');
    data.A_Sum = temp(header:(size(temp)-header));
    fclose(FileHandle); fprintf('|');

    %% Read Sum Voltage B, from file 'g'
    FileHandle = fopen([FilePath filesep 'g' HighFreqFile]);
    temp       = fread(FileHandle,1e10,'float32','ieee-be');
    data.B_Sum = temp(header:(size(temp)-header));
    fclose(FileHandle); fprintf('|');
    
    %% Read Voltage AY, from file ''
    FileHandle = fopen([FilePath filesep '' HighFreqFile]);
    temp = fread(FileHandle,1e10,'float32','ieee-be');
    AY   = temp(header:(size(temp)-header));
    data.A_Y = AY./data.A_Sum;
    fclose(FileHandle); fprintf('|');
    
    %% Read Voltage AX, from file 'b'
    FileHandle = fopen([FilePath filesep 'b' HighFreqFile]);
    temp = fread(FileHandle,1e10,'float32','ieee-be');
    AX   = temp(header:(size(temp)-header));
    data.A_X = AX./data.A_Sum;
    fclose(FileHandle); fprintf('|');

    %% Read Voltage BY, from file 'a'
    FileHandle = fopen([FilePath filesep 'a' HighFreqFile]);
    temp = fread(FileHandle,1e10,'float32','ieee-be');
    BY   = temp(header:(size(temp)-header));
    data.B_Y = BY./data.B_Sum;
    fclose(FileHandle); fprintf('|');

    %% Read Voltage BX, from file 'c'
    FileHandle = fopen([FilePath filesep 'c' HighFreqFile]);
    temp = fread(FileHandle,1e10,'float32','ieee-be');
    BX   = temp(header:(size(temp)-header));
    data.B_X = BX./data.B_Sum;
    fclose(FileHandle); fprintf('|');

    %% Read MirrorX, from file 'd'
    FileHandle = fopen([FilePath filesep 'd' HighFreqFile]);
    temp = fread(FileHandle,1e10,'float32','ieee-be');
    data.Mirror_X = temp(header:(size(temp)-header));
    fclose(FileHandle); fprintf('|');

    %% Read MirrorX, from file 'e'
    FileHandle = fopen([FilePath filesep 'd' HighFreqFile]);
    temp = fread(FileHandle,1e10,'float32','ieee-be');
    data.Mirror_Y = temp(header:(size(temp)-header));
    fclose(FileHandle); fprintf('|');
    
    %% Generate Time Vector
    N = length(data.A_X);
    data.time     = (0:N-1)/fsamp;

    % letter = {'' 'a' 'b' 'c' 'd' 'e' 'f' 'g'}; %the high-freq file is actually a set of 8 files, each one of them contains recordings for one particular voltage
    % Trap A: X, Y, Sum
    % Trap B: X, Y, Sum
    % Mirror Vx, Vy
    % data.AX      = RawData(3,:); 
    % data.AY      = RawData(1,:);
    % data.ASum    = RawData(7,:);
    % data.BX      = RawData(4,:);
    % data.BY      = RawData(2,:);
    % data.BSum    = RawData(8,:);
    fprintf(' done \n');
end
