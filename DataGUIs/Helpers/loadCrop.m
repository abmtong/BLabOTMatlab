function out = loadCrop(cropstr, path, file, prechk)
%Loads the time coordinates of a crop

if nargin < 4
    prechk = 1;
end;

if nargin < 1
    cropstr = '';
end

if nargin < 2
    [file, path] = uigetfile();
end

name = file(1:end-4);
%Create path of crop file
cropfp = sprintf(['%s' filesep filesep 'CropFiles%s' filesep filesep '%s.crop'], path, cropstr, name);
%Try to open the file
fid = fopen(cropfp);
%If no crop, return []
if fid == -1
    %Historically, filename and cropname differ if they're Phage or ForceExt files
    % So try checking for their prefix-stripped names, if possible
    if prechk && length(file) > 5 && strcmpi(file(1:5), 'phage') %Some older data processing has different caps on phage
        name = file(6:end-4);
        out = loadCrop(cropstr, path, [name '.mat'], 0);
    elseif prechk && length(file) > 14 && strcmpi(file(1:14), 'ForceExtension')
        name = file(15:end-4);
        out = loadCrop(cropstr, path, [name '.mat'], 0);
    else
        out = [];
    end
    %Empty if not found, 1x2 if found
    return
end
%Crops are just text files with two numbers, read them
cropT = textscan(fid, '%f');
fclose(fid);
out = cropT{1}'; %Make row
