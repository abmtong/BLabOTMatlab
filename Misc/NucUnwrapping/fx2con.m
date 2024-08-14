function fx2con(infp, inOpts)
%Converts pulling data (force-extension) to contour using a bare DNA pulling curve as reference
% e.g. for Nuc unwrapping, it eventually disassembles to bare DNA: 

%Basically the same as mini2con, but for Nuc data. Could reuse that code?

opts.dnacon = 1600; %Length of handles, kb (not super important: just used as a guess)
opts.frng = [2 35]; %Force range to fix ForExt curve to
opts.cropstr = ''; %Crop string for cropping of DNA part

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Use filepicker
if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        infp = cellfun(@(x)fullfile(p, x), f, 'Un', 0);
    else
        infp = fullfile(p,f);
    end
end

%Handle batch
if iscell(infp)
    cellfun(@(x) fx2con(x, opts), infp)
    return
end

[p, f, e] = fileparts(infp);


%Get f-x crop
cropT = loadCrop(opts.cropstr, p, [f e]);
if isempty(cropT)
    fprintf('No crop found for file %s, skipping\n', f)
    return
end
cd = load(infp); %Should load a struct 'ContourData'
cd = cd.ContourData;

%Get the F and X 
fxind = cd.time >= cropT(1) & cd.time <= cropT(2);
fxx = cd.extension(fxind);
fxf = cd.force(fxind);

%Fit f-x curve
xwlcft = fitForceExt(fxx, fxf, struct('x0', [50 900 opts.dnacon 0 0], 'loF', opts.frng(1), 'hiF', opts.frng(2)  ));

%Convert all data
con = cd.extension ./ XWLC( cd.force, xwlcft(1), xwlcft(2) ) / 0.34;

%Resave (and rename?) (under contour field)
sd = renametophage(cd, 'ContourData');
sd.contour = {con};

%Create subfolder
subdir = fullfile(p, 'fx2con');
if ~exist( subdir , 'dir')
    mkdir( subdir )
end

%Save. Add metadata
stepdata = sd;
stepdata.opts.dnaPL = xwlcft(1);
stepdata.opts.dnaSM = xwlcft(2);
stepdata.opts.dnaCL = xwlcft(3);
save( fullfile(subdir, [f '.mat']), 'stepdata')






