function convertCalDataToOneFile()
%Converts ghe's 8-file to my 1-file caldata

[file, path] = uigetfile('*.dat');
filepath = [path file];
dat = processHiFreq(filepath);
fnames = {'AY' 'BY' 'AX' 'BX' 'MX' 'MY' 'SA' 'SB'};

len = length(dat.AX);
mat = zeros(8, len);

for i = 1:length(fnames)
    mat(i,:) = dat.(fnames{i});
end

fid = fopen([filepath '_new'], 'w');

for i = 1:len/200
    ind1 = 200*(i-1) +1;
    ind2 = 200*i;
    temp = mat(:,ind1:ind2);
    fwrite(fid, temp', 'single');
end
fclose(fid);