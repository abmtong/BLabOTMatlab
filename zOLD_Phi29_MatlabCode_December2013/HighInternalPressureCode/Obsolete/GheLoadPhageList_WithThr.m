function [phageDataInd, ind] = GheLoadPhageList_WithThr(phageData, IndexFile)

%bandList - list of bandwidths
%thrList - list of t-test thresholds

[fileList, stepList, bandList, thrList] = textread(IndexFile, '%s %u %u %f');
totalFiles = unique(fileList);

phageNames = {phageData.file};
phageSteps = [phageData.stID];

ind = [];
Band = [];
for i=1:length(totalFiles)
    % Parse List for unique phage
    phageIndex       = find(strcmp(totalFiles(i), fileList));
    desiredSteps     = stepList(phageIndex);
    desiredBandwidth = bandList(phageIndex);
    
    % Find phage and step index in phageData
    index = find(strcmp(totalFiles(i), phageNames));
    tf = ismember(phageSteps(index), desiredSteps);

    temp = []; %Kludge to find the elements of index1 that correspond to the desired steps
    tempBand = [];
    for j=1:length(tf)
        if tf(j)
            temp = [temp index(j)];
            tempBand = [tempBand desiredBandwidth(sum(tf(1:j)))];
        end
    end
    
    % Produce final index
    ind = [ind temp];
    Band = [Band tempBand];
end

phageDataInd = phageData(ind);

for i=1:length(phageDataInd)
    phageDataInd(i).Band = Band(i);
end
