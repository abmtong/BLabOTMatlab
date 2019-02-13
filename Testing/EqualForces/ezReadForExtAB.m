function ezReadForExtAB()
%Plots a bunch of ForceExtension*.mat files on separate figures, plots -A and B force

%Select files
[file, path] = uigetfile('C:\Data\Analysis\ForceExtension*.mat','Pick your file(s)','MultiSelect','on');
if ~path %no file selected
    return
end
if ~iscell(file)
    file = {file};
end

len = length(file);
for i = 1:len
    load([path file{i}]);
    fa = CalibratedData.ForceAX;
    fb = CalibratedData.ForceBX;
    fay = CalibratedData.ForceAY;
    fby = CalibratedData.ForceBY;
    f = ContourData.force;
    ext = ContourData.extension;
%     t = ContourData.time;

    figure('Name',file{i})
    ax1 = subplot(5,1,[1 2]);
    plot(-fa)
    hold on
    plot(fb)
    ax2 = subplot(5,1,3);
    plot(-fay)
    hold on
    plot(fby)
    linkaxes([ax1 ax2],'x')
    subplot(5,1,[4 5]);
    plot(ext, f)
end