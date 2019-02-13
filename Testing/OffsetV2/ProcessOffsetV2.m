function out = ProcessOffsetV2(filepath)
%Processes a dat file from OffsetV2
if nargin < 1
    [file, path] = uigetfile('C:\Data\*.dat');
    if ~path
        return
    end
    filepath = [path filesep file];
else
    [p, f, e] = fileparts(filepath);
    file = [f e];
    path = [p filesep];
end

d = memmapfile(filepath,'Format','double');

out = reshape(swapbytes(d.Data),8,[],2);
% Row is data lane
% Col is data pt
% Page is avg or sd

%To xform into Ghe's offset file:
offset.path = path;
offset.file = file;
offset.stamp = now;
offset.param = [];
names = {'Mirror_X' 'Mirror_Y' 'A_Sum' 'B_Sum'};
vals = [5 6 7 8];
names2 = {'A_Y' 'B_Y' 'A_X' 'B_X'};
vals2 = [1 2 3 4];
vals3 = [7 8 7 8];
%Order is AX AY BX BY

%Write MX MY SA SB
for i = 1:4
    offset.(names{i}) = out(vals(i),:,1);
    offset.([names{i} '_SD']) = out(vals(i),:,2);
end
%Write normalized AX AY BX BY
for i = 1:4
    offset.(names2{i}) = out(vals2(i),:,1)./out(vals3(i),:,1);
    offset.([names2{i} '_SD']) = out(vals2(i),:,2)./out(vals3(i),:,1);
end
offset.numPoints = ones(1,size(out,2))*15000;


global analysisPath;
save([analysisPath filesep 'offset' file(1:end-4) '.mat'],'offset')