function ReadMiniFile_minaV4_batch(tfrecalc)
%Given a folder structure:
%{
MMDDYY_name1/1A.txt
             1B.txt
             1COM.txt
MMDDYY_name2/1A.txt
             1COM.txt
%}
%Run ReadMiniFile on each file %dA.txt 

%Pick the source folder
p = uigetdir();
if ~p
    return
end

if nargin < 1
    tfrecalc = 0;
end

%Get the child folders (not recursive)
dd = dir(p);
fnams = {dd.name};
tfdir = [dd.isdir];
fnams = fnams(tfdir);

%Strip . and ..
fnams = fnams( ~cellfun(@(x) x(1) == '.', fnams) );

%For each folder, run ReadMiniFile_minaV4 on *A.txt
len = length(fnams);
parfor i = 1:len %Lets just parfor per folder
    %Get the files in this folder
    dd = dir(fullfile(p, [fnams{i} '\']));
    nam = {dd.name};
    %Find '*A.txt' files
    ki = ~cellfun(@isempty, regexp(nam, '.*A\.txt', 'once') );
    nam = nam(ki);
    %Run ReadMiniFile on them
    cellfun(@(x)ReadMiniFile_minaV4(fullfile(p, fnams{i}, x), tfrecalc) , nam)
end