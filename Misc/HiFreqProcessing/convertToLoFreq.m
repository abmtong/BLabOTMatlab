function convertToLoFreq(filepath, nSamples, nFil)
%Turns a multi-sample data stream into a one sample data stream, for loading by other scripts
%Specifically, data saved as [nSamples x nLanes x []] is reshaped into [nLanes x []]
%Since old data is saved big endian, but new little (windows default), bytes are swapped.

nLanes = 8;

if nargin<1 || isempty(filepath)
    [file, path] = uigetfile('*.dat');
    if ~path
        return
    end
    filepath = [path file];
else
    [p, f, e] = fileparts(filepath);
    path = [p filesep];
    file = [f e];
end

if nargin<2 || isempty(nSamples)
    nSamples = 20;
end

if nargin<3 || isempty(nFil)
    nFil = 1;
end

filebak = [path file '_bak'];
movefile(filepath, filebak);

dat = memmapfile(filebak,'Format','single');

d = reshape(dat.Data,nSamples,nLanes,[]);

fid = fopen(filepath,'w');

len = numel(d)/nLanes;

out = zeros(nLanes,floor(len/nFil),'single');
for i = 1:nLanes
    temp = d(:,i,:);
    if nFil > 1
        temp = windowFilter(@mean, temp(:)', [], nFil);
    end
    out(i,:) = temp(:);
end

fwrite(fid, swapbytes(out), 'single');
fclose(fid);
%load file with memmap

%reshape to (20, 8, [])

%collapse to (:, i, :)

%concatenate to (8 [])

%save with fwrite( fid, swapbytes(data), 'single')


end

