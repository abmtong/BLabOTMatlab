function PlotMiniForceExtension()
%Plots (a bunch) of F-X curves

[file, path] = uigetfile('C:\Data\RawData\*.txt','Select Minitweezers F-X files','MultiSelect','on');
if ~iscell(file)
    file = {file};
end

len = length(file);
for i = 1:len
    dat = ReadMiniFile([path filesep file{i}]);
    figure('Name',file{i})
    plot(dat{2},dat{1})
end