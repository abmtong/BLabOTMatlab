function dataPath = SetOldResultsPath(path)
global OldResultsPath;

if nargin < 1
    if isempty(OldResultsPath)
        OldResultsPath = uigetdir();
    else
        if OldResultsPath == 0
            OldResultsPath = uigetdir();
        else
            OldResultsPath = uigetdir(OldResultsPath);
        end
    end
else
    OldResultsPath = path;
end

dataPath = OldResultsPath;