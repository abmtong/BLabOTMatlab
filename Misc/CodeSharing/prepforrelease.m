function prepforrelease(filnam, folnam, links)
%Readies a function for release to others.
% It does so by fetching its dependent .m fi les and finding the dependent toolboxes, too
% Misses function calls in @eval (or similar)
%Prep multiple files for release in the same folder by doing:
% cellfun(@(x)prepforrelease(x, foldername), filenamescell)
%Make sure all the files are accessible by Matlab when you do this (i.e. add them to the search path), else they will be skipped
%Does not preserve file structure, so files may throw warnings if you use @addpath, e.g. (program will still work)

%Get / make mfile filename
if isa(filnam,'function_handle')
    filnam = [func2str(filnam) '.m'];
elseif ischar(filnam)
    %if not appended with .m, add it
    if ~strcmpi(filnam(end-1:end), '.m')
        filnam = [filnam '.m'];
    end
else
    error('Input must be the filename (string), m-file name or function handle');
end

%Specify whether to output files or just shortcuts
if nargin < 3 || isempty(links)
    links = 0;
end

%make folder name if not supplied
if nargin < 2 || isempty(folnam)
    if links
        folnam = [filnam(1:end-2) '_release_lnks'];
    else
        folnam = [filnam(1:end-2) '_release'];
    end
end

%Get file and toolbox dependency
[fl, pl] = matlab.codetools.requiredFilesAndProducts(filnam);

%make output folder
[~, ~, ~] = mkdir(folnam); %tildes are to suppress Warning: Directory already exists
%If we're copying files (links == 0)
if ~links
    %copy dependent files to folder
    cellfun(@(x)copyfile(x, folnam), fl)
else
    %create shortcuts to relevant files (if e.g. you want to clean them up before release
    [~, fnames] = cellfun(@fileparts, fl, 'Uni', 0);
    cellfun(@(x,y) system( sprintf( 'powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut(''%s\\%s.lnk'');$s.TargetPath=''%s'';$s.Save(); exit; &', folnam, x, y) ), fnames, fl );
    %This opens a lot of cmd windows (one per link), I can't seem to close the cmd window programmatically (if you omit the trailing &, the program hangs)
end

%Write toolbox dependencies as text file
deps = {pl.Name};
%check if one already exists
depfname = [folnam filesep 'Dependencies.txt'];
fid = fopen(depfname, 'r');
if fid ~= -1 %file opened correctly, so process it
    %read file, line by line
    lne =fgetl(fid); %read first line
    deps2 = [];
    while lne ~= -1
        deps2 = [deps2 {lne}]; %#ok<AGROW>
        lne = fgetl(fid); %read new line, is -1 if at eof
    end
    fclose(fid);
    %Merge existing and new dependencies
    deps = [deps deps2];
    %Find unique dependencies
    deps = unique(deps);
end
%Write file
fid = fopen(depfname, 'wt'); %open in (over)write/text mode
%write date
fwrite(fid, sprintf('Last updated %s\n', datestr(datetime('now')) ) );
cellfun(@(x)fwrite(fid, sprintf('%s\n', x)), deps);
fclose(fid);