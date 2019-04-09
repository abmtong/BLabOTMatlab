function [outExts, outFrcs] = getFCs_fx(cropstr, path)

if nargin < 1
    cropstr = '';
end
if nargin < 2
    [files, path] = uigetfile('C:\Data\ForceExtension*.mat','MultiSelect','on');
else
    files = dir([path filesep 'ForceExtension*.mat']);
    files = {files.name};
end
if ~path
    return
end
if ~iscell(files)
    files = {files};
end
len = length(files);
outExts = cell(1,len);
outFrcs = cell(1,len);
for i = 1:len
    file = files{i};
    %Load crop
    cropfp = sprintf('%s\\CropFiles%s\\%s.crop',path,cropstr, file(15:end-4));
    fid = fopen(cropfp);
    if fid == -1
        fprintf('Crop%s not found for %s\n', cropstr, file)
        continue
    end
    ts = textscan(fid, '%f');
    fclose(fid);
    crop = ts{1};
    %load file
    load([path file],'ContourData')
    %find start/end index
    indsta = find( ContourData.time > crop(1), 1, 'first');
    indend = find(ContourData.time < crop(2), 1, 'last');
    %crop to pts within crop region
    outExts{i} = ContourData.extension(indsta:indend);
    outFrcs{i} = ContourData.force(indsta:indend);
end