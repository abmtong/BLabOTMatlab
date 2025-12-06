function [out, outraw] = lumKymoVdist(inOpts)

opts.cropstr = ''; %Crop string
opts.filtim = 4; %Filter width, time (seconds), i.e. how much data to filter by
opts.maxnangap = 100; %Maximum region of no data, pts@~50Hz
opts.vbinsz = 2; %Bin size
opts.verbose = 1; %Plot
if nargin
    handleOpts(opts, inOpts);
end

%Select data
[f,p] = uigetfile('*.mat', 'Mu', 'on');
if ~p
    return
end
if ~iscell(f)
    f = {f};
end

len = length(f);
outraw = cell(1, len);
for i = 1:len
    %Load data
    sd = loadCroppedData(fullfile(p, f{i}), opts.cropstr);
    
    %Get data. Assume these are all no-FC data
    Fs = 1/mean( diff([sd.time{:}]) );
    con = [sd.contour{:}];
    
    %Patch holes. This makes con a cell.
    con = lumKymoPatchNan(con, opts.maxnangap);
    
    %sgolaydiff to calc speed
    sgwid = round(Fs * opts.filtim);
    sgwid = sgwid + mod(sgwid+1, 2); %Make odd, as width must be odd
    vel = cellfun(@(x) sgolaydiff(x, {1 sgwid}), con, 'Un', 0);
    vel = [vel{:}];
    
    %Convert slope from /pt to /s
    vel = vel * Fs;
    outraw{i} = vel;
end

%And bin and whatever
vraw = [outraw{:}];

[p, x] = nhistc(vraw, opts.vbinsz);
out = [x(:) p(:)];

if opts.verbose
    figure, plot(x, p)
end









