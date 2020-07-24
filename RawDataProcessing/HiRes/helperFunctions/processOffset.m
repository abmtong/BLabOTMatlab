function out = processOffset(filepath)
%Reads an OffsetV2 file. Not used in AProcessData

%Pick from UI if no file given
if nargin < 1
    [file, path] = uigetfile('C:\Data\*.dat');
    if ~path
        return
    end
    filepath = [path file];
end
%Names chosen to reflect those given by Ghe's programs
name = {'AY' 'BY' 'AX' 'BX' 'MX' 'MY' 'SA' 'SB'};

d=memmapfile(filepath, 'Format', 'double');
%Extract the mean data
for i = 1:length(name)
    out.(name{i}) = swapbytes(d.Data(i:8:end/2));
end
%Extract the SD data
for i = 1:length(name)
    out.([name{i} '_SD']) = swapbytes(d.Data(end/2+i:8:end));
end