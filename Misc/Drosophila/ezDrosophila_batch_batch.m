function out = ezDrosophila_batch_batch(inp)
%Runs ezDrosophila_batch and ezDroAP_batch on all files in folder
% Should be 'smart' to only do what works

% This is semi-active, it'll ask for what folders to do and then for APDV checking at the end

%input: The data folder, which contains the PreProcessedData, ProcessedData, and RawDynamicsData folders

%Output the struct with better data saving (filepaths, etc.)

%Basically, from the raw data, run ezDrosophila_batch_batch
%  You can check if the nc frames are correct or not
% Then run ezSum_batchV2 on the output
% Then run fitRise_batch on the output
% Then run getSpotPos_batch_batch on that output

%Then plot with [plotting functions]


if nargin < 1
    inp = uigetdir('','Choose the overarching Data folder');
    if ~inp
        return
    end
end

%Make sure this has PreProcessedData and ProcessedData files
if ~exist( fullfile(inp, 'PreProcessedData'), 'dir') || ~exist( fullfile(inp, 'ProcessedData'), 'dir')
    error('Wrong folder? Cant find PreProcessedData and ProcessedData folders')
end

%So... ezDro_batch wants a tif in \PreProcessedData\, so let's just get that
dd = dir( fullfile(inp, 'PreProcessedData') );
dd = dd([dd.isdir]); %Get folders
dd = dd(3:end); %Strip . and ..

dirnam = {dd.name}; %And get folder names

%Ask for which folders to actually do
% idl = inputdlg( sprintf('%s (set 0 to skip)',1,length(dirnam)), 'Choose folders', 1, dirnam);

%Aaand actually, set a max length, since the box can become bigger than the screen...
if length(dirnam) <= 50 %50 lines is about the max for a 1080p screen (and at default font size?)
    %Create folder names as a msgbox
    def = cellfun(@(x) sprintf('''%s'' \n', x), dirnam, 'Un', 0); %Add '' and a trailing space for eval later...
    def = {[ def{:} ] };
    
    idl = inputdlg( 'Choose folders (delete to skip)', '', [length(dirnam)+1, 100], def );
    %If cancel is hit, exit
    if isempty(idl)
        return
    end
    
    %idl is a n_line x wid char array, padded with spaces, of '%s' (with a trailing space)
    % We should be able to eval it into a cell array... {'%s' '%s' '%s' etc.}
    % Or could do the 'better' thing of finding first and second ' and taking the between...
    %  Actually, since files can have apostrophes, we need to do the better thing
    
    %Split into lines
    idl = idl{1};
    idl = mat2cell( idl, ones(1,size(idl, 1)), size(idl, 2) );
    %Remove all empty
    idl( cellfun(@(x) all(x == ' '), idl) ) = [];
    %Find first and last apostrophe
    aps = cellfun(@(x) strfind(x, ''''), idl, 'Un', 0);
    %Get string between edge apostrophes
    idl = cellfun(@(x,y) x(y(1)+1:y(end)-1), idl, aps, 'Un', 0);

    %And this is dirnam. Make it a row vector.
    dirnam = idl';
    
%     %Hmm do equals '1'
%     ki = cellfun(@(x) isequal(x, '1'), idl);
%     dirnam = dirnam(ki);
else
    warning('Too many folders to select, taking all of them')
end

len = length(dirnam);

out = cell(1,len);
for i = 1:len
    %Get a .tif file in this folder
    d = dir( fullfile( inp, 'PreProcessedData', dirnam{i}, '*.tif') );
    
    %Just try-catch it to handle bad data
%     try
        dat = ezDrosophila_batch( fullfile( inp, 'PreProcessedData', dirnam{i}, d(2).name) );
%     catch
%         warning('Data %s failed', dirnam{i})
%         continue
%     end
    
    %If worked, assemble to output struct
    tmp.fol = dirnam{i}; %Folder name, like a full name
    %Create a shorter name, YYMMDD-R#E#
    datdate = dirnam{i}([3 4 6 7 9 10]); %YYMMDD from YYYY-MM-DD
    datre = dirnam{i}(find( dirnam{i} == '-', 1, 'last')+1 : end);
    tmp.nam = [datdate '-' datre];
    tmp.dat = dat;
    
    %Guess fr from ezSum_prep
    tmp.fr = ezSum_prep(dat);
    
    %And add to struct
    out{i} = tmp;
    
    fprintf('Data extraction for data %s done\n', tmp.nam)
end

%Do APDV at the end so they're together, since these are interactive (checking APDV)
for i = 1:len
    %If ezDro_batch worked...
    if isempty(out{i})
        continue
    end
    
    %See if RawDynamicsData\dirnam{i} exists
    tmp2 = struct('apdv',[],'movpos',[], 'embimg', []); %Create an empty struct of what ezDroAP_batch would do
    midfp = fullfile( inp, 'RawDynamicsData', dirnam{i},'Mid_Mid_RAW_ch01.tif');
    if exist(midfp , 'file' )
        try
            tmp2 = ezDroAP_batch(out{i}.dat, midfp);
        catch
            warning('APDV Data for %s found but processing failed', dirnam{i})
        end
    end
    
    %Add to struct. For failed/missing ezDroAP_batch, it'll be empty
    out{i}.apdv = tmp2.apdv;
    out{i}.movpos = tmp2.movpos;
    out{i}.embimg = tmp2.embimg;
    
    %Plot check
    if ~isempty(out{i}.apdv)
        ezDroAP_check(out{i}, 1);
        drawnow
    end
    
end

%Merge to struct
out = [out{:}];










