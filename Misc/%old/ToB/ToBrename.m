function ToBrename()
%Converts a texture file (*.dat) in TOTEX_P into a .dds by trimming the first 4 bytes, changing extension
%Old ver, newer on Desktop

[files, path] = uigetfile('*.dat','MultiSelect', 'on');
if ~iscell(files)
    temp = files;
    files{1}={temp};
end
mkdir([path filesep 'dds']);
for i = 1:length(files);
    inFile = fopen([path filesep files{i}]);
    inData = fread(inFile);
    outFile = fopen([path filesep 'dds' filesep files{i}(1:end-3) 'dds'], 'w');
    fwrite(outFile, inData(5:end));
end
fclose all;
end

