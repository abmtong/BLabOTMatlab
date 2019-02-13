function ezReadPhageFX()
%Plots a bunch of ForceExtension*.mat files on separate figures

%Select files
[file, path] = uigetfile('C:\Data\Analysis\ForceExtension*.mat','Pick your file(s)','MultiSelect','on');
if ~file %no file selected
    return
end
if ~iscell(file)
    file = {file};
end

len = length(file);
for i = 1:len
    load([path filesep file{i}]);
    f = ContourData.force;
    x = ContourData.extension;
    %t = ContourData.time;
    figure('Name',file{i})
    plot(x,f)
end