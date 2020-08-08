function AProcessData(filepath, inOpts)
%Processes raw data into ones usable by other tools
%Input text file structure, placed in the same folder as MMDDYYN##.dat files
    %033117 {date of experiments in MMDDYY format}
    %01 03 02 comment {data offset calibration comment}
    %etc.

%Where you usually store data (Not required, just saves on navigation)
defaultPath = 'C:\Data\*.txt'; 

%Add requried paths
thispath = fileparts(mfilename('fullpath'));
addpath(thispath);
addpath([thispath '\Calibration\']); %Where Calibration code is
addpath([thispath '\helperFunctions\']); %Where data reading code is

%Get file from UI if not specified
if ~exist('filepath','var') || isempty(filepath)
    [file, path] = uigetfile(defaultPath,'Select your text file');
    if ~path %No file selected
        return
    end
    filepath=[path file];
else
    [p, f, e] = fileparts(filepath);
    path = [p filesep];
    file = [f e]; %#ok<NASGU>
end

opts.gheNames = 1;
%Apply any input opts
if exist('inOpts','var') && isstruct(inOpts)
    opts = handleOpts(opts, inOpts);
end

%Parse the text file: First read file as separate lines
fid = fopen(filepath);
txtlines = textscan(fid, '%s','Delimiter','\n','Whitespace',''); %could also while(ischar(fgetl(fid)))
fclose(fid);
txtlines = txtlines{1};
%First is date, format into string [should be ok to use as-is, but might have whitespace]
mmddyy = sprintf('%06d', str2double(txtlines{1}));
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

%Prompt for settings
prompts  = {'Sampling Frequency (Hz)' 'Number of Samples in Data' 'Number of Detectors in Data' 'Change Endian?' ...
            'Trap X Offset(V)' 'Trap Y Offset(V)' 'Trap X Conversion (nm/V)', 'Trap Y Conversion (nm/V)' ...
            'Bead Radius (nm) A (Movable trap)' 'Bead Radius (nm) B (Fixed trap)' ...
            '0=ForExt, 1=Semi-passive, 2=Force feedback' ...
            'XWLC PL(nm), 50D 40R 35H' 'XWLC SM(pN), 700D 450R 500H' 'kT (pN nm)' 'Rise/bp (nm/bp)'...
            'Ext Offset (e.g. Capsid Size) (nm)'...
            'Custom options, e.g. {''cal.wV'', ''0.97e-9'';}'};
defaults = {'2500' '1' '8' 'true' ...
            '1.40', '1.05' '758.4' '577.2' ... 
            '1000/2' '1000/2' ...
            '1' ...
            '40' '900' '(273+27)*.0138' '0.34'...
            '50'... %Capsid is 44nm + antibody stem ~ 5-10nm
            '{''cal.wV'', ''0.91e-9'';}'};
fnames   = {'Fsamp' 'numSamples' 'numLanes' 'numEndian' ...
            'offTrapX' 'offTrapY' 'convTrapX' 'convTrapY' ...
            'raA' 'raB' ...
            'isPhage' ...
            'dnaPL' 'dnaSM' 'dnakT' 'dnaBp'...
            'extOffset' ...
            };
resp = inputdlg(prompts,'Data Parameters',1,defaults);
if isempty(resp)
    return
end
%Since the last option is handled differently, extract it
custresp = resp{end};
resp = resp(1:end-1);
%All settings are numbers, so convert to vector and assign to opts struct
if isempty(resp) || any(cellfun(@isempty,resp))
    %Cancel clicked or at least one response was empty, can't continue
    fprintf('Parameters missing, exiting.\n')
    return
end
%Use str2num over str2double so expressions such as '1000/2' or 'true' evaluate to 500, logical(1) instead of NaN
%However, cellfun needs uniform output, so need to convert logicals to double
resp = cellfun(@(x)double(str2num(x)), resp); %#ok<ST2NM>
%Assign to opts struct
for i = 1:length(fnames)
    opts.(fnames{i}) = resp(i);
end

%Calibration lorentzian type (see @Lorentzian)
opts.cal.lortype = 3;

%Check if custom options field was changed, and assign the options if they were
if ~strcmp(defaults{end}, custresp)
    custoptcell = eval(custresp);
    if iscell(custoptcell)
        for i = 1:size(custoptcell, 1)
            eval(sprintf('custopts.%s = %s;', custoptcell{i,1}, custoptcell{i,2}))
        end
        opts = handleOpts(opts, custopts);
    else
        fprintf('Custom option parsing failed, exiting\n')
        return
    end
end

%Sanity check: Date
d = dir([path mmddyy '*']);
if isempty(d)
    fprintf('No files found starting with %s, are you sure the date is right?\n', mmddyy)
    return
end

%Process each file
for i = 1:size(nndat,1)
    %If cal has already been plotted, don't plot it again. It's still recalculated, but that takes little time
    if any(nndat(i,3) == nndat(1:i-1,3))
        opts.cal.verbose = 0;
    else
        opts.cal.verbose = 1;
    end
    opts.comment = coms{i};
    try
        ProcessOneData([path mmddyy 'N.dat'], nndat(i,:), opts);
    catch %There are some common mistakes when writing down the data triplet, account for them here
        try
            %Swap off and cal
            ProcessOneData([path mmddyy 'N.dat'], nndat(i,[1 3 2]), opts);
            warning('Data/off/cal [%d %d %d] rearranged to [%d, %d, %d].\n', nndat(i,:), nndat(i,[1 3 2]));
        catch
            try %Add one to dat and off
                ProcessOneData([path mmddyy 'N.dat'], nndat(i,:)+[0 1 1], opts);
                warning('Data/off/cal [%d %d %d] shifted to [%d, %d, %d].\n', nndat(i,:), nndat(i,:)+[0 1 1]);
            catch
                warning('Data/off/cal [%d %d %d] failed.\n', nndat(i,:));
            end
        end
    end
end

%Prompt for cleanup: Move raw data to a separate folder or to the recycle bin.
switch questdlg('Would you like to move the Raw Data files?','Cleanup?','To subfolder','Delete','No','No');
    case 'To subfolder'
        movefile([path '*N*.dat'], [path 'RawData' filesep])
    case 'Delete'
        %Turn recycle on, delete, revert to previous recycle state
        rec = recycle;
        recycle on
        delete([path mmddyy 'N*.dat'])
        recycle(rec)
end