function data = WiggleCal_ReadHighFreqFile(Fsamp,FilePath,HighFreqFile)
% Reads high frequency binary data file(s), outputs raw voltages to
% structure cell array "data". This function does not normalize the x,y
% voltages. It works one file at a time
%
% data = WiggleCal_ReadHighFreqFile(Fsamp,FilePath,HighFreqFile)
%
% Gheorghe Chistol, 15 April 2011

letter = {'' 'a' 'b' 'c' 'd' 'e' 'f' 'g'}; %the high-freq file is actually a set of 8 files, each one of them contains recordings for one particular voltage
% Trap A: X, Y, Sum
% Trap B: X, Y, Sum
% Mirror Vx, Vy

header = 85; %the files have a header that has to be removed
display(['... Loading ' HighFreqFile]);

for i = 1:8
    CurrentFile = [letter{i} HighFreqFile]; 
    % Parse data
    FileHandle = fopen([FilePath CurrentFile]);
    Temp = fread(FileHandle,1e10,'float32','ieee-be');
    RawData(i,:) = Temp(header:(size(Temp)-header));
    fclose(FileHandle);
    %clear RawData;
end

N = length(RawData(1,:));
data.FilePath = FilePath;
data.File     = HighFreqFile;
data.Fsamp    = Fsamp;
data.AX      = RawData(3,:); %read the raw voltage data, without normalizing it
data.AY      = RawData(1,:);
data.ASum    = RawData(7,:);
data.BX      = RawData(4,:);
data.BY      = RawData(2,:);
data.BSum    = RawData(8,:);
data.MirrorX = RawData(5,:);
data.MirrorY = RawData(6,:);
data.Time     = (0:N-1)/Fsamp;