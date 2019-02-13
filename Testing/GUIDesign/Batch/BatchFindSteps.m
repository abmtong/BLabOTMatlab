function out = BatchFindSteps(findStepFcn, filterOpts, stepOpts, outStr, cherrypick)
%Applies findStepFcn to every cropped trace in a folder (select by GUI)
%Takes a function handle, and a cell array of options for filtering and stepfinding
%Filtered trace = windowFilter(filterOpts{1}, trace, filterOpts{2:end})
%[in me tr] = findStepFcn(trace, stepOpts{:})

narginchk(4,5)

if nargin < 5
    cherrypick = 0;
end

%isempty filteropts is below

if isempty(stepOpts)
    stepOpts = {[]};
end
keep = 0;
toss = 0;

%Choose folder
path = uigetdir('C:\Data\JP DNA-RNA Dec''16 May''17\JP data may 2017\','Choose the folder with your phi29 traces'); %Doing a hard-coded default path for now
if ~path
    return
end
%Grab suitable files in the folder
files = dir([path filesep 'phage*.mat']);
fileNames = {files.name};

%Arrays to hold data from each trace file
outDwells = cell(1,length(fileNames));
outBursts = cell(1,length(fileNames));

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
    dw = cell(1,length(con));
    bu = cell(1,length(con));
    
    %Display progress message
    fprintf('Starting file %d of %d, has up to %d segments\n', i, length(fileNames), sum( ~cellfun(@isempty,(stInd)) & ~cellfun(@isempty, enInd)))
    %Loop over each segment
    for j = 1:length(con)
        %Extract the cropped segment of the trace
        trace = con{j}(stInd{j}:enInd{j}); %empty one/both of the ind's dont exist
        
        %Don't process empty/tiny traces (tiny traces are due to imperfections of Ghe's segmenting algorithm)
        if length(trace) < 100
            continue
        end
        
        %Filter the trace
        if ~isempty(filterOpts)
            trace = windowFilter(filterOpts{1}, trace, filterOpts{2:end});
        end
        
        %Apply the stepfinding
        [inds, means, trafit] = findStepFcn(trace, stepOpts{:});
        if cherrypick
            f = figure('Position',[200 200 1920/1.3 1080/1.3]);
            plot(trace, 'Color', [0.8 0.8 0.8])
            hold on
            plot(smooth(trace), 'Color', [0.8 0.8 1])
            plot(trafit, 'Color', 'k')
            drawnow
            response = questdlg('Keep this one?','Keep?','Yes','No','No');
            close(f);
        else
            response = 'Yes';
        end
        switch response
            case 'Yes'
                %Convert output to numbers we want
                dw{j} = diff(inds(2:end-1)); %Don't count dwells on edges
                bu{j} = -diff(means);
                keep = keep + 1;
            otherwise
                toss = toss + 1;
        end
    end
    %Store results in array
    outDwells{i} = dw;
    outBursts{i} = bu;
end
save([path filesep outStr '.mat'],'outDwells', 'outBursts');

%Plot histogram
f = figure('Name',outStr);
out = collapseCell(outBursts);
p=(normHist(out,0.2));
bar(p(:,1),p(:,2))
zoom on

%Save results

savefig(f, [path filesep outStr]);

str= '';
if cherrypick
    str = sprintf('Kept %0.2f%% of traces',keep*100/(keep+toss));
end
fprintf('BatchFindSteps finished %d traces in %0.2fm. %s\n', length(fileNames), toc(startT)/60, str);