function dataPath = SetRawDataPath(path)

global rawDataPath;

if nargin < 1
    if isempty(rawDataPath)
        rawDataPath = uigetdir('C:\Data\','Choose raw data path');
    else
        rawDataPath = uigetdir(rawDataPath);
    end
    if rawDataPath == 0
        rawDataPath = pwd;
    end
else
    rawDataPath = path;
end

dataPath = rawDataPath;