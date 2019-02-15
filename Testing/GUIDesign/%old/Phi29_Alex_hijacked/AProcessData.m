function AProcessData(filepath, inOpts)
%HIJACKED FOR TESTING

%Processes raw data into ones usable by other tools
%Input text file structure, placed in the same folder as MMDDYYN##.dat files
    %033117 {date of experiments in MMDDYY format}
    %01 03 02 comment {data offset calibration comment}
    %etc.

%Where you usually store data (Not required, just saves on navigation)
defaultPath = 'E:\011718\*.txt'; 

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
%Preallocate the matrix to hold data numbers, comments
nndat = zeros(len, 3);
coms = cell(len,1);
for i = 1:len
    %Stop at first empty line
    if isempty(txtlines{i+1})
        nndat = nndat(1:i-1,:);
        break
    end
    %Scan each line for 'num num num comment'. Can't do this from the start since e.g. '04 03 02' has no trailing %s, which causes textscan to stop.
    linedat = textscan(txtlines{i+1}, '%d %d %d %s','Whitespace','\t');
    %Insert numbers into array
    nndat(i,1:3) = [linedat{1:3}];
    %Extract comment, handle empty case
    note = linedat{4};
    if isempty(note)
        note = {''};
    end
    coms{i} = note{1};
end

%Prompt for settings
prompts  = {'Sampling Frequency (Hz)' 'Number of Samples in Data' 'Number of Detectors in Data' 'Change Endian?' ...
            'Trap X Offset(V)' 'Trap Y Offset(V)' 'Trap X Conversion (nm/V)', 'Trap Y Conversion (nm/V)' ...
            'Bead Radius (nm) A (Movable trap)' 'Bead Radius (nm) B (Fixed trap)' ...
            'Is Phage Data? Note: WLC param.s below are for Phage only' ...
            'DNA Persistence Length (nm)' 'DNA Stretch Modulus (pN)' 'kT (pN nm)' 'DNA Rise/bp (nm/bp)'...
            'Custom options'};
defaults = {'2500' '1' '8' 'true' ...
            '1.4', '0.9' '762' '578' ...
            '1000/2' '1000/2' ...
            'true' ...
            '60' '550' '(273+27)*.0138' '0.34'...
            '{''fname'',''value'';}'};
fnames   = {'Fsamp' 'numSamples' 'numLanes' 'numEndian' ...
            'offTrapX' 'offTrapY' 'convTrapX' 'convTrapY' ...
            'raA' 'raB' ...
            'isPhage' ...
            'dnaPL' 'dnaSM' 'dnakT' 'dnaBp'};
resp = inputdlg(prompts,'Data Parameters',1,defaults);
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
    %If cal has already been plotted, don't plot it again
%     if any(nndat(i,3) == nndat(1:i-1,3))
        opts.cal.verbose = 0;
%     else
%         opts.cal.verbose = 1;
%     end
    opts.comment = coms{i};
    
    ProcessOneData([path mmddyy 'N.dat'], nndat(i,:), opts);
    
%     bf = 0.6:0.2:1.4;
%     for j = 1:length(bf)
%         for k = 1:length(bf)
%             if j + k > 2
%                 opts.cal.verbose = 0;
%             end
%             baf = bf(j);
%             bbf = bf(k);
%             opts.raA = opts.raA * baf;
%             opts.raB = opts.raB * bbf;
%             ProcessOneData([path mmddyy 'N.dat'], nndat(i,:), opts);
%             opts.raA = opts.raA / baf;
%             opts.raB = opts.raB / bbf;
%             %Rename the file to add B1.150.98, e.g., to show bead size values
%             movefile(sprintf('%sPhage%sN%02d.mat',path, mmddyy, nndat(i,1)), sprintf('%sPhage%sN%02dA%0.2fB%0.2f.mat',path, mmddyy, nndat(i,1), baf, bbf));
%         end
%     end
end

%Prompt for cleanup: Move raw data to a separate folder or to the recycle bin.
% switch questdlg('Would you like to move the Raw Data files?','Cleanup?','To subfolder','Delete','No','No');
%     case 'To subfolder'
%         movefile([path '*N*.dat'], [path 'RawData' filesep])
%     case 'Delete'
%         %Turn recycle on, delete, revert to previous recycle state
%         rec = recycle;
%         recycle on
%         delete([path mmddyy 'N*.dat'])
%         recycle(rec)
% end