function out = loadCrop(cropstr, path, file)
%Loads the time coordinates of a crop

if nargin < 1
    cropstr = '';
end

if nargin < 2
    [file, path] = uigetfile();
end

%Filename and cropname might differ if they're Phage or ForceExt files
if length(file) > 5 && strcmpi(file(1:5), 'phage') %Some older data processing has different caps on phage
    name = file(6:end-4);
elseif length(file) > 14 && strcmpi(file(1:14), 'ForceExtension')
    name = file(15:end-4);
else
    name = file(1:end-4);
end

%Create path of crop file
cropfp = sprintf('%s\\CropFiles%s\\%s.crop', path, cropstr, name);
%Try to open the file
fid = fopen(cropfp);
%If no crop, return []
if fid == -1
    out = [];
    return
end
%Crops are just text files with two numbers, read them
cropT = textscan(fid, '%f');
fclose(fid);
out = cropT{1}'; %Make row