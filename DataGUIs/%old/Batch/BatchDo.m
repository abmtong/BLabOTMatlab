function outResult = BatchDo(doFcn, outStr)
%Helper fcn for doing batch operations on cropped traces
%Does inFcn(tr) over all segments of cropped traces in the selected directory.
%Most often called from another fcn, which defines a special doFcn and handles the output, too
%The output is arranged in a cell.

if nargin <2 || isempty(outStr)
    a = inputdlg('Name your output .mat file');
    outStr = a{1};
end

%Choose folder
path = uigetdir('C:\Data\','Choose the folder with your phi29 traces'); %Doing a hard-coded default path for now
if ~path
    return
end
%Grab suitable files in the folder
files = dir([path filesep 'phage*.mat']);
fileNames = {files.name};

%Allocate for every file's result
outResult = cell(1,length(fileNames));

%Helper functions to find the relevant start/end indices of each segment (what's in the crop)
cellfindfirst = @(stT)(@(times)(find(times > stT,1)));
cellfindlast =  @(enT)(@(times)(find(times < enT,1,'last')));

startT = tic;
%Loop over each file
for i = 1:length(fileNames)
    %Load crop
    name = fileNames{i}(6:end-4); %Extracts * from phage*.mat
    cropfp = sprintf('%s\\CropFiles\\%s.crop', path, name);
    fid = fopen(cropfp);
    if fid == -1
        fprintf('Crop not found for %s\n', name)
        continue
    end
    
    crop = textscan(fid, '%f');
    fclose(fid);
    crop = crop{1};
    
    %Load the file, extract the trace
    load([path filesep fileNames{i}]);
    con = stepdata.contour;
    tim = stepdata.time;
    Fs = 1/diff(tim{1}(1:2));
    
    %Find the cropped start/stop index of each segment of the trace (outside crop -> empty index)
    stInd = cellfun(cellfindfirst(crop(1)), tim,'UniformOutput',false);
    enInd = cellfun(cellfindlast (crop(2)), tim,'UniformOutput',false);
    
    %Allocate for every segment's result
    trResult = cell(1,length(con));
    
    %Display progress message
    fprintf('Starting file %d of %d, has %d segments\n', i, length(fileNames), sum( ~cellfun(@isempty,(stInd)) & ~cellfun(@isempty, enInd)))
    %Loop over each segment
    for j = 1:length(con)
        %Extract the cropped segment of the trace
        trace = con{j}(stInd{j}:enInd{j}); %empty one/both of the ind's dont exist
        %Don't process empty/tiny traces
        if length(trace) < 0.2*Fs %Minimum length: 0.2s
            continue
        end
        %Do fcn
        trResult{j} = doFcn(trace);
    end
    %Store results in cell
    outResult{i} = trResult;
end
save([path filesep outStr '.mat'],'outResult');

str= '';
fprintf('Batch finished %d traces in %0.2fm. %s\n', length(fileNames), toc(startT)/60, str);