function outDwells = BatchFindSteps(filter, width, decimate, str)

if nargin < 1
    filter = @median;
end
if nargin < 2
    width = 3; %pts on each side
end
if nargin < 3
    decimate = 2; %keep every nth point
end

%Load GUIsettings
if exist('GUIsettings.mat','file')
    load('GUIsettings.mat')
    if ~exist ('filePath','var')
        filePath = '';
    end
else %Otherwise, create it
    filePath = '';
    c='Settings file for Phage GUI';
    save GUIsettings.mat c;
end

[fileNames, filePath] = uigetfile([filePath filesep 'phage*.mat'],'Multiselect','on','Pick your Phi29 traces');

if nargin < 4
    str = inputdlg('File Name [-.mat]','Save output as...');
end

%Make it a cell if we need to
if ~iscell(fileNames)
    name = fileNames;
    fileNames = cell(1);
    fileNames{1} = name;
end

outDwells = cell(1,length(fileNames));
outBursts = cell(1,length(fileNames));

for i = 1:length(fileNames)
    name = fileNames{i}(6:end-4); %phage*.mat -> *
    ind = findCellField(crops, name);
    if ind == size(crops,1)+1
        fprintf([name ' is not cropped, skipping.\n'])
    else
        load([filePath filesep fileNames{i}]);
        con = stepdata.contour;
        tim = stepdata.time;
        
        cellfindfirst = @(startT)(@(times) (find(times > startT,1,'first')));
        cellfindlast =  @(endT)  (@(times) (find(times < endT  ,1,'last')));
        
        %Returns a cell array that is either the bdy if within crop, or empty if not in the crop
        startInd = cellfun(cellfindfirst(crops{ind,2}(1)), tim,'UniformOutput',false);
        endInd   = cellfun(cellfindlast(crops{ind,2}(2)), tim,'UniformOutput',false);
        
        dw = cell(1,length(con));
        bu = cell(1,length(con));
        for j = 1:length(con)
            trace = con{j}(startInd{j}:endInd{j}); %empty if one of the ind's dont exist
            if length(trace) > 100 %dont process empty / tiny traces
                [inds, means] = AFindSteps(windowFilter(filter,trace,width,decimate),100, 9*estimateNoise(trace) );    %,log(length(trace)));
                dw{j} = diff(inds);
                bu{j} = -diff(means);
            end
        end
        outDwells{1} = dw;
        outBursts{i} = bu;
    end
end

save([filePath filesep str '.mat'],'outDwells', 'outBursts');