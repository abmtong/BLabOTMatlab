function qpNVbatch(minfsize)

if nargin < 1
    minfsize = 3;
end

[f, p] = uigetfile('F:\BackUpFrom180GBHardDisk\2008\*.dat', 'MultiSelect', 'on');
if ~p
    return
end
if ~iscell(f)
    f = {f};
end
len = length(f);
for i = 1:len
    w = dir([p f{i}]);
    fsz = w.bytes / 1024^2;
    if fsz < minfsize
        continue
    end
    try
        quickPlotNV(f{i}, p)
    catch
    end
end