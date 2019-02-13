function sortCrops()
%Sorts GUIsettings.mat/crops, for OCD reasons, I guess?

load('GUIsettings.mat')
cropsort = crops(2:end,1);
[~, sortInd] = sort(cropsort);
crops = crops([1 sortInd'+1],:);

save('GUIsettings.mat','crops','-append')