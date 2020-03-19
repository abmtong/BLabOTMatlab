function out = ACalibrate( filepath, inOpts )
%Calibrates the HiRes optical tweezer's bead parameters (trap conversion alpha, spring constant kappa)
%Uses theoretical power spectrum from tweezercalib2.1 (doi:10.1016/j.cpc.2004.02.012)
%See processHiFreq to see the file structure of calibration files
%Inputs: filepath of the first calibration data, MMDDYYN##.dat, options

%Last commented 191210

%Default options
opts.raA = 1000/2;
opts.raB = 1000/2;
opts.verbose = 1;
opts.lortype = 3;
%Colors of plots: [lightGreen lightBlue; darkGreen darkBlue]
opts.colors = {[.2039 .5961 .8588] [.1608 .5020 .7255];...
               [.1804 .8000 .4431] [.1529 .6824 .3765]};

%Add requried paths
thispath = fileparts(mfilename('fullpath'));
addpath(thispath);
addpath([thispath '\..\helperFunctions\']); %Where @handleOpts, @processHiFreq is

%Process inOpts param
if nargin > 1
    opts = handleOpts(opts, inOpts);
end
colors = opts.colors;

%Pick file via UI if not specified. Separate into [path, file]
if nargin < 1 || isempty(filepath)
    [file, path] = uigetfile('*.dat', 'Mu', 'on');
    if ~path
        return
    end
    %Batch and save if iscell
    if iscell(file)
        nf = length(file);
        out = cell(1,nf);
        for i = 1:nf
            out{i} = ACalibrate(fullfile(path, file{i}), opts);
            fg = gcf;
            [~, f, ~] = fileparts(file{i});
            savefig(fg, fullfile(path, ['cal' f '.fig']));
        end
        return
    else
        filepath = [path file];
    end
else
    [path, f, e] = fileparts(filepath);
    file = [f e];
end

%Load data
dat = processHiFreq(filepath);

if opts.verbose
    %Define plot window
    scrsz = get(groot,'ScreenSize');
    sz = [scrsz(3:4)*.2 scrsz(3:4)*.6];
    figure('Name',sprintf('%s Calibration',file), 'Position',sz)
end
%Laser sums
opts.SumA = mean(dat.SA);
opts.SumB = mean(dat.SB);

%Char arrays for naming structs
c1 = 'AB';
c2 = 'XY';
%Calculate calibration, organize into figure
for i = 1:2
    I = c1(i);
    opts.ra = opts.(['ra' I]);
    for j = 1:2
        J = c2(j);
        opts.name = [I J];
        opts.color = colors{i,j};
        opts.Sum = opts.(['Sum' I]);
        if opts.verbose
            opts.ax = axes('Position',[-.45+0.5*i, 1.05-0.5*j,  0.43, 0.43]);
        end
        out.([I J]) = Calibrate(dat.([I J])./dat.(['S' I]), opts);
    end
end

%Assign to output
out.opts = opts;
out.raA = opts.raA;
out.raB = opts.raB;
out.path = path;
out.file = file;
out.timestamp = datestr(now, 'yy/mm/dd HH:MM:SS');
