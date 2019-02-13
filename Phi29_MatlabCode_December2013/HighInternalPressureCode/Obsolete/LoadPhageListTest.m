function [phageDataInd, ind, fileList, stepList] = LoadPhageList(phageData)

global analysisPath;

if isempty(analysisPath)
    startpath = [pwd '\'];
else
    startpath = [analysisPath '\'];
end

[file, path] = uigetfile([startpath '*.txt']);

[fileList, stepList] = textread([path file], '%s %u');

totalFiles = unique(fileList);

phageNames = {phageData.file};
phageSteps = [phageData.stID];

ind = [];
for i=1:length(totalFiles)
    % Parse List for unique phage
    phageIndex = find(strcmp(totalFiles(i), fileList));
    desiredSteps = stepList(phageIndex);
    
    % Find phage and step index in phageData
    index1 = find(strcmp(totalFiles(i), phageNames));
    tf = ismember(phageSteps(index1), desiredSteps);
        
    temp = []; %Kludge to find the elements of index1 that correspond to the desired steps
    for j=1:length(tf)
        if tf(j)
            temp = [temp index1(j)];
        end
    end
    
    % Produce final index
    ind = [ind temp];
end
%{
for i=1:length(fileList)
    ind1 = find(strcmp({phageData.file}, fileList{i}));
    ind2 = find([phageData.stID] == stepList(i));
    ind(i) = intersect(ind1, ind2);
end
%}

phageDataInd = phageData(ind);
display(['Loaded ' path file]); 
