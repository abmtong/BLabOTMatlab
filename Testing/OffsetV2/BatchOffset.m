function BatchOffset( filepath )
global rawDataPath;

if nargin < 1
    [file, path] = uigetfile('*.txt');
    if ~path
        return
    end
    filepath = [path file];
end

fid = fopen(filepath);
scn = textscan(fid, '%s %s %s');
len = length(scn{2});

for i = 1:len
    file = scn{2}{i};
    fname = [rawDataPath filesep file(7:end) '.dat'];
    ProcessOffsetV2(fname);
end