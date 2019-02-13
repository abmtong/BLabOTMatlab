function crops = convertCropsV2(filePath)
%Saves the crops as selected_dir\Crops.mat, instead of in GUISettings.mat

if nargin < 1
    filePath = uigetdir('C:\Data\');
end

%Load GUIsettings
file = [filePath filesep 'Crops.mat'];
if exist(file,'file')
    load('GUIsettings.mat')
else
    crops = {'cropped_file','[crop_time_start crop_time_end]'};
    c='Saved Crops';
    save(file, 'c');
end

files = dir([filePath filesep 'phage*.mat']);
fileNames = {files.name};

if ~exist([filePath filesep 'CropFiles'],'dir');
    disp('no CropFiles dir')
    return;
end

for i = 1:length(fileNames)
    name = fileNames{i}(6:end-4); %phage012345N67.mat -> 0123456N67
    CropFile = [filePath filesep 'CropFiles' filesep name '.crop'];
    if exist(CropFile,'file')
        FileID = fopen(CropFile); %open the *.crop file
        startX = sscanf( fgetl(FileID),'%f'); %parse the first line, which is the start time
        stopX  = sscanf( fgetl(FileID),'%f'); %parse the second line, which is the stop time
        fclose(FileID);
        
        ind = findCellField(crops,name);
        crops{ind,1} = name;
        crops{ind,2} = [startX stopX];
    else
        fprintf(['No crop for ' name ', skipping.\n']);
    end
end
save(file,'crops','-append');