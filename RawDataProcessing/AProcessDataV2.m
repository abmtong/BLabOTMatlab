function AProcessDataV2(infp, opts)
%V2: Works for other instruments, not just HiRes

%Load text file. This must be located where the other .dat files are
if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.txt', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        opts = DataOptsPopup;
        cellfun(@(x)AProcessDataV2(fullfile(p, x), opts), f)
        return
    else
        infp = fullfile(p,f);
    end
end
[p, f, e] = fileparts(infp);
f = [f e];

%Set data opts
if nargin < 2
    opts = DataOptsPopup;
end

opts = handleOpts(struct('path', p), opts);

%Parse text file. Same code as from V1
fid = fopen(fullfile(p,f));
txtlines = textscan(fid, '%s','Delimiter','\n','Whitespace',''); %could also while(ischar(fgetl(fid)))
fclose(fid);
txtlines = txtlines{1};
%First is date, format into string [should be ok to use as-is, but might have whitespace]
mmddyy = sprintf('%06d', str2double(txtlines{1}));
%Sanity check for mmddyy
if ~(str2double(txtlines{1}) > 010000)
    inp = input('Date seems wrong, whats is the date?');
    mmddyy = sprintf('%06d', str2double(inp));
end
len = length(txtlines)-1;
%Preallocate the matrix to hold data numbers, comments, and options changes
nndat = zeros(len, 3);
coms = cell(len,1);
pre = []; %prefix
pos = 1; %nndat row position
for i = 1:len
    %Skip empty lines
    if isempty(txtlines{i+1})
        continue
    end
    %check if first char is %, indicating comment
    if txtlines{i+1}(1) == '%'
        pre = txtlines{i+1}(2:end);
        continue
    end
    %Scan each line for 'num num num comment'. Can't do this from the start since e.g. '04 03 02' has no trailing %s, which causes textscan to stop.
    linedat = textscan(txtlines{i+1}, '%d %d %d %s','Whitespace','\t');
    %Get numbers
    tempnum = [linedat{1:3}];
    if numel(tempnum) ~= 3
        fprintf('Skipping line: %s\n', txtlines{i+1})
        continue
    end
    %Insert numbers into array
    nndat(pos,1:3) = tempnum;
    %Extract comment, handle empty case
    note = linedat{4};
    if isempty(note)
        note = {''};
    end
    coms{pos} = [pre ' ' note{1}];
    pos = pos + 1;
end
nndat = nndat(1:pos-1,:);
coms = coms(1:pos-1,:);

opts.mmddyy = mmddyy;

%Add req'd paths, also get data name filter for cleanup later
thispath = fileparts(mfilename('fullpath'));
switch opts.Instrument
    case 'HiRes'
        addpath([thispath filesep 'HiRes'])
        datname = '*N*.dat'; %MMDDYYN##.dat
    case 'Meitner'
        addpath([thispath filesep 'Timeshared'])
        datname = '*_*.dat'; %MMDDYY_###.dat
    case 'Boltzmann'
        addpath([thispath filesep 'Timeshared'])
        datname = '*_*.dat'; %MMDDYY_###.dat
    case 'Mini'
        addpath([thispath filesep 'Minitweezers'])
        datname = '*_*.dat'; %MMDDYY_###.dat
    case 'Lumicks'
        addpath([thispath filesep 'Lumicks'])
        datname = '*.h5';    %Name.h5
end

%To debug, we can't have the error be caught for dbstop to fire
debug = 0; %#ok<*UNRCH>
if debug
    warning('Debugging AProcessData')
end

%Then ProcessOneData these. Same code from V1
for i = 1:size(nndat,1)
    %If cal has already been plotted, don't plot it again. It's still recalculated, but that takes little time
    if any(nndat(i,3) == nndat(1:i-1,3))
        opts.cal.verbose = 0;
    else
        opts.cal.verbose = 1;
    end
    opts.comment = coms{i};
    if debug
        ProcessOneDataV2(p, nndat(i,:), opts);
    else
        try 
            ProcessOneDataV2(p, nndat(i,:), opts);
        catch %There are some common mistakes when writing down the data triplet, account for them here
            try
                %Swap off and cal
                ProcessOneDataV2(p, nndat(i,[1 3 2]), opts);
                warning('Data/off/cal %s [%d %d %d] rearranged to [%d, %d, %d].', mmddyy, nndat(i,:), nndat(i,[1 3 2]));
            catch
                try %Add one to dat and off
                    ProcessOneDataV2(path, nndat(i,:)+[0 1 1], opts);
                    warning('Data/off/cal %s [%d %d %d] shifted to [%d, %d, %d].', mmddyy, nndat(i,:), nndat(i,:)+[0 1 1]);
                catch
                    warning('Data/off/cal %s [%d %d %d] failed.\n', mmddyy, nndat(i,:));
                end
            end
        end
    end
end

% %Actually, don't use this anymore?
% %Prompt for cleanup: Move raw data to a separate folder or to the recycle bin.
% %Ask the user what to do
% switch questdlg('Would you like to move the Raw Data files?','Cleanup?','To subfolder','Delete','No','No');
%     case 'To subfolder'
%         movefile([path datname], [path 'RawData' filesep])
%     case 'Delete'
%         %Recycle the files -- turn recycle on, delete, revert to previous recycle state
%         rec = recycle;
%         recycle on
%         delete([path mmddyy datname])
%         recycle(rec)
% end

end
