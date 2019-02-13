function outDwells = BatchFindSteps_Batch_Hist(filter, width, decimate, str, inFilePath, fileNames, inP, useExt)
%Gets files passed as a var, not as a ui prompt
if nargin < 1
    filter = @median;
end
if nargin < 2
    width = 3; %pts on each side
end
if nargin < 3
    decimate = 2; %keep every nth point
end
if nargin < 7
    inP = [];
end
if nargin < 8
    useExt = 0;
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
        load([inFilePath filesep fileNames{i}]);
        con = stepdata.contour;
        tim = stepdata.time;
        
        if useExt
            realcon = con;
            con = stepdata.extension;
        end
        
        
        cellfindfirst = @(startT)(@(times) (find(times > startT,1,'first')));
        cellfindlast =  @(endT)  (@(times) (find(times < endT  ,1,'last')));
        
        %Returns a cell array that is either the bdy if within crop, or empty if not in the crop
        startInd = cellfun(cellfindfirst(crops{ind,2}(1)), tim,'UniformOutput',false);
        endInd   = cellfun(cellfindlast(crops{ind,2}(2)), tim,'UniformOutput',false);
        
        dw = cell(1,length(con));
        bu = cell(1,length(con));
        for j = 1:length(con)
            trace = con{j}(startInd{j}:endInd{j}); %empty if one of the ind's dont exist
            if length(trace) > 100 && ~prod(isnan(trace)) %dont process empty / tiny / NaN traces
                trf = windowFilter(filter,trace,width,decimate);
                %                           V7d, V8c
                if useExt
                    res = 0.05;
                else
                    res = 0.2;
                end
                [inds, means] = findStepHistV8c(trf, res, estimateNoise(trf, 125/decimate), inP );    %,log(length(trace)));
                
                
                if useExt
                    %Calculate means - the step heights
                    trace2 = realcon{j}(startInd{j}:endInd{j});
                    trf2 = windowFilter(filter, trace2, width, decimate);
                    means = zeros(1,length(inds)-1);
                    for k = 1:length(means)
                        means(k) = mean(trf2(inds(k):inds(k+1)));
                    end
                end
                
                dw{j} = diff(inds);
                bu{j} = -diff(means);
            end
        end
        outDwells{i} = dw;
        outBursts{i} = bu;
    end
end

save([inFilePath filesep str '.mat'],'outDwells', 'outBursts');