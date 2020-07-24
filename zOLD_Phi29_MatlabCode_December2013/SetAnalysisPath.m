function dataPath = SetAnalysisPath(path);

global analysisPath;

if nargin < 1
    if isempty(analysisPath)
        analysisPath = uigetdir('C:\Data\','Choose analysis path');
    else
        if analysisPath == 0
            analysisPath = uigetdir('C:\Data\','Choose analysis path');
        else
            analysisPath = uigetdir(analysisPath);
        end
    end
else
    analysisPath = path;
end

dataPath = analysisPath;