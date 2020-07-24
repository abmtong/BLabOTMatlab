function convertOffV2toOffV3()
%Converts offV2, which is formatted big endian, double, has SD info; to one little, single, without

[file, path] = uigetfile('*.dat');
filepath = [path file];
dat = readDat(filepath, 1, 8, 'double', 1);

dat = dat(:,1:(end/2));

fid = fopen([filepath '_new'], 'w');
    fwrite(fid, dat, 'single');
fclose(fid);