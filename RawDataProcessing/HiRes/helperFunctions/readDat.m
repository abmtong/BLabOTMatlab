function out = readDat(filepath, numSamples, numLanes, fileFormat, changeEndian)
%Reads a *.dat file of data, of any type. Pass [] for filepath to pick from UI.
%Useful (numSamples,numLanes) values: HiFreq 62.5kHz is (200,8), Data is (1,8) for 2.5kHz or (20,8) for 50kHz

%Defaults
if ~exist('changeEndian','var') || isempty(changeEndian)
    changeEndian = true;
end
if ~exist('fileFormat','var') || isempty(fileFormat)
    fileFormat = 'single';
end
if ~exist('numLanes','var') || isempty(numLanes)
    numLanes = 8;
end
if ~exist('numSamples','var') || isempty(numSamples)
    numSamples = 1;
end

%Pick from UI if no filepath specified
if ~exist('filepath','var') || isempty(filepath)
    [file, path] = uigetfile('C:\Data\*.dat');
    if ~path
        return
    end
    filepath = [path file];
else
    [p, f, e] = fileparts(filepath);
    path = [p filesep]; %#ok<NASGU> - Won't be used, but keep around if it will be
    file = [f e];
end

mmap = memmapfile(filepath, 'Format', fileFormat);
out = mmap.Data;

if changeEndian
    out = swapbytes(out);
end

%Check for proper length. Will be checked for anyway in @reshape, but prefer to error here.
if mod(length(out), numSamples*numLanes)
    error('Error reading file %s: numLanes or numSamples seems wrong', file)
end

%Reshape this (1,[]) vector into a (numLanes,[]) matrix, with each row being one detector
%One sample is simple, so take shortcut
if numSamples == 1
    out = reshape(out, numLanes, []);
else
    %For multiple samples, use @permute and @reshape
    %Data is (nSamples) x (nLanes) x (nPts), need to concatenate dims 1 and 3, make dim 2 leading
    out = reshape(permute(reshape(out, numSamples, numLanes, []) ,[2 1 3]) ,numLanes,[]);
end