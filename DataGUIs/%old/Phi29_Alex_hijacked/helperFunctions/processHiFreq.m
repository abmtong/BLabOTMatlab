function out = processHiFreq(filepath)
% Reads high frequency data files, outputs each channel in a struct

if nargin < 1
    [file, path] = uigetfile('*.dat');
    if ~path
        return
    end
else
    [path, file, ext] = fileparts(filepath);
    file = [file ext];
end

%Not all of these are needed for brownian calibration, we can skip MX and MY, but keep anyway
letter = {''   'a'  'b'  'c'  'd'  'e'  'f'  'g'};
name =   {'AY' 'BY' 'AX' 'BX' 'MX' 'MY' 'SA' 'SB'};
%The files have an 42-double (336-byte) header that contains the transfer polynomial coefficients - we don't need them, so just remove
header = 336;
%Extract the data, change endianness
for i = 1:length(letter)
    mmp = memmapfile([path filesep letter{i} file],'Format','single','Offset',header);
    out.(name{i}) = swapbytes(mmp.Data);
end
%For current VIs, data should be [625400x1 single = 200*3127]
if any( structfun(@length,out) ~= 625400 )
    warning('Length of data in %s seems wrong (~=625400)', file)
end