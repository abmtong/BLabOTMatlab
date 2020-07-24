function plotAllFigs(binSize)

if nargin<1
    binSize = 0.2;
end

path = uigetdir('D:/Data');

names = dir([path filesep '*.mat']);

names = {names.name};

for i = 1:length(names)
    nam = names{i};
    load([path filesep nam])
    if exist('outBursts','var')
        figure('Name',nam)
        p = normHist(collapseCell(outBursts), binSize);
        bar(p(:,1),p(:,2))
        clear outBursts;
    end
end
