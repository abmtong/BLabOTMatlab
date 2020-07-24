function dataPath = SetRawDataPath(path)

global rawDataPath;

if nargin < 1
    if isempty(rawDataPath)
        rawDataPath = uigetdir();
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