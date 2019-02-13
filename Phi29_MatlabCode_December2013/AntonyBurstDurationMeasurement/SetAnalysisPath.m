function dataPath = SetAnalysisPath(path);

global analysisPath;

if nargin < 1
    if isempty(analysisPath)
        analysisPath = uigetdir();
    else
        if analysisPath == 0
            analysisPath = uigetdir();
        else
            analysisPath = uigetdir(analysisPath);
        end
    end
else
    analysisPath = path;
end

dataPath = analysisPath;