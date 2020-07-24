function [outData, outRawData, rawColNames] = ReadMiniFile_minaV3(filepath)
%Reads a minitweezers data file. First output gives you {force, extension, time}, rest are are all the raw values
%V3: Works now with differing file column headers (searches by column name instead of hard-coded column number)

%Columns we want:
minifns = {'time(sec)', 'A_dist-Y', 'Tension'};
savefns = {'time', 'contour', 'force'};

if nargin < 1 || isempty(filepath)
    %Grab, load file if not supplied
    [file, path] = uigetfile('.txt');
    filepath = [path filesep file];
end
fid = fopen(filepath);

%Grab column names, while skipping rows that start with # (the first and last row, and skipped values)
while true
    hdr = fgetl(fid); %Find first line that isn't a comment
    if hdr(1) ~= '#'
        break
    end
end

%Extract column names into string array
rawColNames = textscan(hdr, '%s');
rawColNames = rawColNames{1}';
numColumns = length(rawColNames);

%Create formatting string ('%f ' repeated numColumns times)
fmt = repmat('%f ',1,numColumns);

%Read data
outRawData = textscan(fid, fmt,'CommentStyle','#');

%Trim the data to what we want - force (tension), extension, time
stepdata = [];
for i = 1:length(savefns)
    stepdata.(savefns{i}) = outRawData(:, find(strcmp(minifns{i}, rawColNames),1));
end

%Save as phage MAT file for opening
save([filepath(1:end-4) '.mat'], 'stepdata');

if nargout > 1
    outData = stepdata;
end





