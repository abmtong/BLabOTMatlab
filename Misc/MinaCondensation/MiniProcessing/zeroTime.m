function zeroTime(inp)
%Takes a folder structure thats like this:
% \Parent\Condition\abcd.mat
%And for each mat file, runs mini2con on it, then splitcondfiles

%Run-one-and-done, for testing eg XWLC fitting options


if nargin < 1
    inp = uigetdir('D:\Data\');
    if isempty(inp)
        return
    end
end




%Input: Parent folder, that contains folders for each separate trace
dd = dir(inp);

%Get folders
isf = [dd.isdir];
dd = dd(isf);
dd = dd(3:end); %Strip '.' and '..'
folnams = {dd.name};

%For each folder...
for i = 1:length(folnams)
    %Get mat files
    curdir = fullfile(inp, folnams{i});
    dd = dir(fullfile( curdir, '*.mat'));
    nams = {dd.name};
    
    for j= 1:length(nams)
        %Load
        fp = fullfile(inp, folnams{i}, nams{j});
        sd = load(fp);
        stepdata = sd.stepdata;
        %Zero time
        stepdata.time{1} = stepdata.time{1} - stepdata.time{1}(1);
        %Save
        save(fp, 'stepdata')
    end
end



