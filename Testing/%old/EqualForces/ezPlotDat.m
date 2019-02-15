function ezPlotDat()
[file, path] = uigetfile('E:\Data (Temp)\RawData\*.dat','Select your .dat files','MultiSelect','on');
if ~iscell(file)
    file = {file};
end

len = length(file);

for i = 1:len
    d = processDat([path filesep file{i}]);
    fax = -d.ax./d.sa;
    fay = -d.ay./d.sa;
    fbx = d.bx./d.sb;
    fby = d.by./d.sb;
    fax = fax - mean(fax(1:100));
    fbx = fbx - mean(fbx(1:100));
    fay = fay - mean(fay(1:100));
    fby = fby - mean(fby(1:100));
    figure('Name',file{i})
    plott(fax, fbx, fay, fby)
end