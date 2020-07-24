function out = BatchFindVelocity(filterOpts, outStr)
%Uses BatchFindSteps code

if nargin < 1 || isempty(filterOpts)
    filterOpts = {@mean, [], 10};
end

if nargin <2
    a = inputdlg();
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

%Arrays to hold data from each trace file
outVels = cell(1,length(fileNames));

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
    
    %Find the cropped start/stop index of each segment of the trace (outside crop -> empty index)
    stInd = cellfun(cellfindfirst(crop(1)), tim,'UniformOutput',false);
    enInd = cellfun(cellfindlast (crop(2)), tim,'UniformOutput',false);
    
    %Create array to hold this file's dwell times and burst heights
    ve = cell(1,length(con));
    
    %Display progress message
    fprintf('Starting file %d of %d, has up to %d segments\n', i, length(fileNames), sum( ~cellfun(@isempty,(stInd)) & ~cellfun(@isempty, enInd)))
    %Loop over each segment
    for j = 1:length(con)
        %Extract the cropped segment of the trace
        trace = con{j}(stInd{j}:enInd{j}); %empty one/both of the ind's dont exist
        time = tim{j}(stInd{j}:enInd{j});
        %Filter
        trace = windowFilter(filterOpts{1}, trace, filterOpts{2:end});
        time = windowFilter(filterOpts{1}, time, filterOpts{2:end});
        
        %Don't process empty/tiny traces (tiny traces are due to imperfections of Ghe's segmenting algorithm)
        if length(trace) < 50
            continue
        end
        
        %Fit a line
        pfit = polyfit(time-time(1), trace-trace(1), 1);
        ve{j} = pfit(1);
    end
    %Store results in cell
    outVels{i} = ve;
end
save([path filesep outStr '.mat'],'outVels');

%Plot histogram
f = figure('Name',outStr);
out = collapseCell(outVels);
p=(normHist(out,2.5));
bar(p(:,1),p(:,2))
zoom on

%Save results

savefig(f, [path filesep outStr]);

str= '';
fprintf('Batch finished %d traces in %0.2fm. %s\n', length(fileNames), toc(startT)/60, str);