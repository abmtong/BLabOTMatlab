function out = RPpass_p1(infp, inOpts)
%Processes a passive mode data file, splitting at trap sep bdys

opts.fil = 200; %Filter
opts.filtyp = 2; %Median
opts.minhold = 5e5; %Minimum 20s passive

%Options for splitting
opts.dsamp = 1000; %Filtering for passive mode splitting
opts.kvpen = single(100); %K-V penalty for splitting. Fiddle with this to change sensitivity (higher = less sensitive)
opts.trim = 1e4; %Amount to strip from ends of sections, try ~0.1s

if nargin > 2
    opts = handleOpts(opts, inOpts);
end

%Get file
if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    
    if iscell(f)
        %Handle batch
        tmp = cellfun(@(x) RPpass_p1( fullfile(p, x), opts), f, 'Un', 0);
        out = [tmp{:}];
        return
    else
        infp = fullfile(p, f);
    end
end

%Store filename
[p, f, e] = fileparts(infp);

%Load file
dat = load(infp);
dat = dat.ContourData;

frc = dat.force;
ext = dat.extension;

% %Convert to contour using XWLCparams
% conpro = ( ext - XWLC(frc, xwlcparams(1), xwlcparams(2)) * xwlcparams(3) ) ./ XWLC( frc, xwlcparams(end-1), inf);

%Estimate trap separation from ext and frc
trappos = ext - dat.forceAX/dat.cal.AX.k + dat.forceBX/dat.cal.BX.k;

%Check for crop
crp = loadCrop('', p, [f e]);
%If exists, crop. Else, take all
if ~isempty(crp)
    ki = dat.time > crp(1) & dat.time < crp(2);
    frc = frc(ki);
    ext = ext(ki);
    trappos = trappos(ki);
end


%Split cycles by changes in trap sep:
%Downsample
trapposF = windowFilter(@median, trappos, [], opts.dsamp);

%Find changes with KV? with changes in 

%Stepfind with KV
[in, ~] = AFindStepsV5(trapposF, opts.kvpen, [], 0);
%Undo downsampling
in = in * opts.dsamp;

%And split
len = length(in) - 1;
frcs = cell(1,len);
exts = cell(1,len);
% cons = cell(1,len);
tpos = cell(1,len);
for i = 1:len
    %Make sure this snip is long enough
    if in(i+1) - in(i) < opts.minhold
        %Otherwise skip
        continue
    end
    
    %Grab sections, trimming edges
    ki = in(i) + opts.trim : in(i+1) - opts.trim -1;
    
    frcs{i} = frc(ki);
    exts{i} = ext(ki);
%     cons{i} = conpro(ki);
    tpos{i} = trappos(ki);
end

%Remove skippeds
ki = cellfun(@length, frcs) > 0;
frcs = frcs(ki);
exts = exts(ki);
tpos = tpos(ki);

%Assemble to cell
out = struct('file', f, 'ext', exts, 'frc', frcs, 'tpos', tpos );





















