function out = ACalibrate( filepath, inOpts )
%


%Defaults
opts.raA = 1000/2;
opts.raB = 1000/2;
opts.save = 0;

%Process inOpts param
if nargin >=2 && isstruct(inOpts)
    fn = fieldnames(inOpts);
    for i = 1:length(fn)
        opts.(fn{i}) = inOpts.(fn{i});
    end
end

%Pick file via UI if not specified
if nargin < 1 || isempty(filepath)
    [file, path] = uigetfile('*.dat');
    if ~path
        return
    end
    filepath = [path file];
else
    [~, f, e] = fileparts(filepath);
    file = [f e];
end

%Load data
dat = processHiFreq(filepath);

%Colors of plots
colors = {[.2039 .5961 .8588] [.1608 .5020 .7255];...
          [.1804 .8000 .4431] [.1529 .6824 .3765] };

%Define plot window
scrsz = get(groot,'ScreenSize');
sz = [scrsz(3:4)*.2 scrsz(3:4)*.6];
figure('Name',sprintf('%s Calibration',file), 'Position',sz)

%Char arrays for naming structs
c1 = 'AB';
c2 = 'XY';
for i = 1:2
    I = c1(i);
    opts.ra = opts.(['ra' I]);
    for j = 1:2
        J = c2(j);
        opts.ax = axes('Position',[-.45+0.5*i, 1.05-0.5*j,  0.43, 0.43]);
        opts.name = [I J];
        opts.color = colors{i,j};
        out.([I J]) = Calibrate(dat.([I J])./dat.(['S' I]), opts);
        cal.(['alpha' I J]) = out.([I J]).a;
        cal.(['kappa' I J]) = out.([I J]).k;
    end
end

if opts.save
    %Format to Ghe's cal file, save
    cal.path = path;
    cal.file = file;
    cal.stamp = now;
    cal.date = date;
    cal.beadRadiusA = opts.raA;
    cal.BeadRadiusB = opts.raB;
    
    global analysisPath; %#ok<TLEV>
    if ~analysisPath
        analysisPath = uigetdir();
        if ~analysisPath
            return %dont save
        end
    end
    Result = out; %#ok<NASGU>
    save([analysisPath filesep file(1:end-4) '.mat'], 'Result', 'cal')
end