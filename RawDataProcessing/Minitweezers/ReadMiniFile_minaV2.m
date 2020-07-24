function [outData, outRawData, rawColNames] = ReadMiniFile_minaV2(filepath)
%Reads a minitweezers data file. First output gives you {force, extension, time}, rest are are all the raw values

%Columns:
   %CycleCount/n	A_PsdY	A_PsdSum	A_Iris	B_PsdY	B_PsdSum	B_Iris	X_force	Y_force	Z_force	Tension	A_dist-Y	B_dist-Y	time(sec)	Status
%Using extra columns is fine, too few is bad
numColumns = 13;

if nargin < 1 || isempty(filepath)
    %Grab, load file if not supplied
    [file, path] = uigetfile('.txt');
    filepath = [path filesep file];
end
fid = fopen(filepath);

%Grab column names, while skipping rows that start with # (the first and last row, and skipped values)
rawColNames = textscan(fid,'%s',numColumns,'CommentStyle','#');

%Create formatting string ('%f ' repeated numColumns times)
fmt = repmat('%f ',1,numColumns);

%Read data
outRawData = textscan(fid, fmt,'CommentStyle','#');

%Trim the data to what we want - force (tension), extension, time
outData = cell(1,3);
outData{1} = outRawData{end-3}'; %Force
% outData{2} = ((outRawData{end-3}+outRawData{end-2})/2)'; %is this correct? empirically, it seems so
outData{2} = outRawData{end-2}'; %Distance
outData{3} = (outRawData{end}-outRawData{end}(1))'; %Time

%Save as phage MAT file for opening
stepdata.time = outData(3);
stepdata.contour = outData(2);
stepdata.force = outData(1); 
save([filepath(1:end-4) '.mat'], 'stepdata');





