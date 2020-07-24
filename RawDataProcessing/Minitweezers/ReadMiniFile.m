function [outData, outRawData, rawColNames] = ReadMiniFile(filepath)
%Reads a minitweezers data file. First output gives you {force, extension, time}, rest are are all the raw values

%File has 9 columns (Cycle#, ForceX, ForceY, ForceZ, Tension, PosAY, PosBY, Time, Status)
%Using extra columns is fine, too few is bad
numColumns = 9;

if nargin < 1 || isempty(filepath)
    %Grab, load file if not supplied
    [file, path] = uigetfile('.txt');
    filepath = [path filesep file];
end
fid = fopen(filepath);

%Grab column names, while skipping rows that start with # (the first and last row)
rawColNames = textscan(fid,'%s',numColumns,'CommentStyle','#');

%Create formatting string ('%f ' repeated numColumns times)
fmt = repmat('%f ',1,numColumns);

%Read data
outRawData = textscan(fid, fmt);

%Trim the data to what we want - force, extension, time
outData = cell(1,3);
outData(1) = outRawData(5);
outData{2} = (outRawData{6}+outRawData{7})/2; %is this correct? empirically, it seems so
outData{3} = outRawData{8}-outRawData{8}(1);