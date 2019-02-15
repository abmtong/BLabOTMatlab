function stats = plotForcesBatch()
path = uigetdir('C:\Data\Analysis\');
a = dir([path filesep 'Force*.mat']);
b = {a.name};
len = length(b);
stats = zeros(1,len);
for i = 1:len
    stats(i) = plotForces([path filesep b{i}],0);
end

