function out = ACalibrate( filepath, inOpts )
%Calibrates the 'HiRes' optical tweezer's bead parameters (trap conversion alpha, spring constant kappa)
%Uses theoretical power spectrum from tweezercalib2.1 (doi:10.1016/j.cpc.2004.02.012)

%Defaults
opts.raA = 1000/2;
opts.raB = 1000/2;
opts.verbose = 1;

%Process inOpts param
if exist('inOpts','var') && isstruct(inOpts)
    fn = fieldnames(inOpts);
    for i = 1:length(fn)
        opts.(fn{i}) = inOpts.(fn{i});
    end
end

%Add requried paths
thispath = fileparts(which('ACalibrate'));
addpath(thispath);
addpath([thispath '\..\helperFunctions\']); %Where data reading code is

%Pick file via UI if not specified
if nargin < 1 || isempty(filepath)
    [file, path] = uigetfile('*.dat');
    if ~path
        return
    end
    filepath = [path file];
else
    [path, f, e] = fileparts(filepath);
    file = [f e];
end

%Load data
%If file is small (2444KB) it's old HiFreq data, if it's larger (8*2444KB = 19552KB) it's one file (Probably wont implement this)
fprops = dir(filepath);
fsize = fprops.bytes;
if fsize > 3e6
    tmp = readDat(filepath, 200);
    fnames = {'AY' 'BY' 'AX' 'BX' 'SA' 'SB'};
    finds = {1 2 3 4 7 8};
    for i = 1:6
        dat.(fnames{i}) = tmp(finds{i},:);
    end
else
    dat = processHiFreq(filepath);
end
%Colors of plots
colors = {[.2039 .5961 .8588] [.1608 .5020 .7255];...
          [.1804 .8000 .4431] [.1529 .6824 .3765] };

if opts.verbose
  %Define plot window
  scrsz = get(groot,'ScreenSize');
  sz = [scrsz(3:4)*.2 scrsz(3:4)*.6];
  figure('Name',sprintf('%s Calibration',file), 'Position',sz)
end
%Char arrays for naming structs
c1 = 'AB';
c2 = 'XY';
for i = 1:2
    I = c1(i);
    opts.ra = opts.(['ra' I]);
    for j = 1:2
        J = c2(j);
        if opts.verbose
            opts.ax = axes('Position',[-.45+0.5*i, 1.05-0.5*j,  0.43, 0.43]);
            opts.name = [I J];
            opts.color = colors{i,j};
        end
        out.([I J]) = Calibrate(dat.([I J])./dat.(['S' I]), opts);
    end
end

%Code for when data is loaded as a matrix, not struct
%{
datnames = {'AX' 'AY' 'BX' 'BY'}
datinds = [3 1 4 2];
suminds = [7 7 8 8];
posxy = {[.05 .55], [.05 .05], [.55 .55], [.55 .05]};
wid = .43;
for i = 1:length(datinds)
        opts.ax = axes('Position',[posxy{i} wid wid]);
        opts.name = datnames{i};
        opts.color = colors{i}; %TODO: rearrange colors to make sense
        out.(datnames{i}) = Calibrate(dat(datinds(i),:)./dat(suminds(i)), opts);
end
%}

out.opts = opts;
out.raA = opts.raA;
out.raB = opts.raB;
out.path = path;
out.file = file;
out.timestamp = datestr(now, 'yy/mm/dd HH:MM:SS');
