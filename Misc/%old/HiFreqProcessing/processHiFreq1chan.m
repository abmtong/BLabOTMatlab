function out = processHiFreq1chan(filepath)

%Cal data is now saved in one file, which is a series of 200x8 matricies, each column containing data on one sensor

if nargin < 1
    [file, path] = uigetfile('*.dat');
    if ~path
        return
    end
    filepath = [path file];
end

file = memmapfile(filepath,'Format','single');
%Should not need to swapbytes anymore

out = file.Data;