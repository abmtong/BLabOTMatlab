function crops = convertCrops(fileNames, filePath)

%Load GUIsettings
if exist('GUIsettings.mat','file')
    load('GUIsettings.mat')
    if ~exist ('filePath','var')
        filePath = '';
    end
    if ~exist ('crops','var')
        crops = {'cropped_file','[crop_time_start crop_time_end]'};
    end
else %
    filePath = '';
        crops = {'cropped_file','[crop_time_start crop_time_end]'};
    c='Settings file for Phage GUI';
    save GUIsettings.mat c;
end

if nargin < 1
    [fileNames, filePath] = uigetfile([filePath filesep 'phage*.mat'],'Multiselect','on','Pick your Phi29 traces');
end


%Make it a cell if we need to
if ~iscell(fileNames)
    name = fileNames;
    fileNames = cell(1);
    fileNames{1} = name;
end

if ~exist([filePath filesep 'CropFiles'],'dir');
    disp('no CropFiles dir')
    return;
end

for i = 1:length(fileNames)
    name = fileNames{i}(6:end-4); %phage012345N67.mat -> 0123456N67
    CropFile = [filePath filesep 'CropFiles' filesep name '.crop'];
    if exist(CropFile,'file')
        fid = fopen(CropFile); %open the *.crop file
        startX = sscanf( fgetl(fid),'%f'); %parse the first line, which is the start time
        stopX  = sscanf( fgetl(fid),'%f'); %parse the second line, which is the stop time
        fclose(fid);
        
        ind = findCellField(crops,name);
        crops{ind,1} = name;
        crops{ind,2} = [startX stopX];
    end
end
save('GUIsettings.mat','crops','-append');