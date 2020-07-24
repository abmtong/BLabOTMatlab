function out = processHiFreqV2(filepath, nSamples)

if nargin < 2
    nSamples = 200;
end

%Cal data is now saved in one file, which is a series of 200x8 matricies, each column containing data on one sensor

if nargin < 1 || isempty(filepath)
    [file, path] = uigetfile('*.dat');
    if ~path
        return
    end
    filepath = [path file];
end

%File is now little endian, double (instead of big, single)
%DAQ Rate is 500k/s = 3.81MB/s (double), 1.91MB/s (single); filesize 38MB or 19MB
file = memmapfile(filepath,'Format','single');

%Keep the same struct naming scheme for compatability
name = {'AY' 'BY' 'AX' 'BX' 'MX' 'MY' 'SA' 'SB'};
in = reshape(file.Data, nSamples, 8, []); %Third dimension should be 3127 with VI's DataLength = 3125 (generally, = DataLength+2)

for i = 1:8
    temp = in(:,i,:);
    out.(name{i}) = temp(:);
    %Code below also works, but is ~15% slower
    %out.(name{i}) = reshape(in(:,i,:),[],1);
end