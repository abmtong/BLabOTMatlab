function out = getDates(inp)
%Get the dates of the 


if nargin < 1
    inp = uigetdir();
    if ~inp
        return
    end
end

%Get the child folders (not recursive)
dd = dir(inp);
fnams = {dd.name};
tfdir = [dd.isdir];
fnams = fnams(tfdir);

%Strip . and ..
fnams = fnams( ~cellfun(@(x) x(1) == '.', fnams) );

%For each folder, get unique dates
len = length(fnams);
rawout = cell(1,len);
for i = 1:len
    %Get the files in this folder
    dd = dir(fullfile(inp, [fnams{i} '\']));
    nam = {dd.name};
    %Find 'MMDDYYN##.txt' files
    ki = ~cellfun(@isempty, regexp(nam, '.*\.mat', 'once') );
    nam = nam(ki);
    %Get first six chars (MMDDYY)
    nam = cellfun(@(x) x(1:min(6, length(x))), nam, 'Un', 0);
    nam = unique(nam);
    rawout{i} = nam;
end

out = struct('folnam', fnams, 'days', rawout);