function out = RPzerohopp1(infp, inOpts)

%RP for '0 force jump' data
%Like RPhop but care less about unfolding time, just split by trap sep
% Doing some shortcuts that assumes this is timeshared data (i.e. trap sep is pretty exact)

opts.wid = [5 1000]; %Grab this neighborhood around transitions. Grab more for 'safety', plot less later

%WLC fitting per-pull
opts.xwlcfit = 3; %Do fitting. Set 0 to use backup, 2 for fitPFFD, 1 for just DNA crop
opts.otherfxdata = 0; %Data for pull is from a separate file
opts.cropstrfx = 'fx'; %Crop string for initial pulling curve
opts.xwlcfil = 30; %Filter and downsample XWLC pull by this much
opts.xwlcguess = [50 900 700]; %XWLC guess / fallback
opts.xwlcfrng = [1.5 30]; %XWLC fit range
opts.xwlcffoldmin = 4; %Unfolding force minimum for rip detection: try 4 unless the protein unfolds lower

opts.cropstr = ''; %Crop string for hopping data
opts.pwlcc = 104 * 0.35; %Protein contour length, only if xwlcfit == 2

opts.Foff = 0; %Force offset, set or obtained from XWLC fit (if allowed)

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


if nargin < 1
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        out = cellfun(@(x) RPzerohopp1(fullfile(p,x)), f, 'Un', 0);
        for i = 1:length(out)
            [out{i}.file] = deal(f{i});
        end
        out = [out{:}];
        return
    end
    infp = fullfile(p,f);
end

%Load file
cd = load(infp);
cd = cd.ContourData;
[p f e] = fileparts(infp);

%XWLC fitting
if opts.otherfxdata
    [ffx, pfx] = uigetfile('*.mat', 'Select F-X Data File', 'Mu', 'on');
    if ~pfx
        fxfp = infp;
        warning('Using same file for F-X')
    else
        fxfp = fullfile(pfx,ffx);
    end
else
    fxfp = infp;
end

if opts.xwlcfit == 1
    %Load crop
    [pfx, ffx, efx] = fileparts(fxfp);
    xcT = loadCrop(opts.cropstrfx, pfx, [ffx efx]);
    
    %Crop
    ki = cd.time > xcT(1) & cd.time < xcT(2);

    xfrc = cd.force(ki);
    xext = cd.extension(ki);
    
    %Downsample
    xfrc = windowFilter(@mean, double(xfrc), [], opts.xwlcfil);
    xext = windowFilter(@mean, double(xext), [], opts.xwlcfil);
    
    %Fit to XWLC
    fitfcn = @(x0,x) XWLC(x, x0(1), x0(2)) * x0(3);
    oop = optimoptions('lsqcurvefit', 'Display', 'off');
    xft = lsqcurvefit(fitfcn, opts.xwlcguess, double(xfrc), double(xext), [0 0 0], [inf inf inf], oop);
    
    xwlcparams = xft;
elseif opts.xwlcfit == 2
    %Use fitPFFD: Crop pre-rip in cropstr fx and post-rip in cropstr fx2
    fpopts = struct('pwlcc', opts.pwlcc, 'dsamp', opts.xwlcfil, 'pwlcg', opts.pwlcg);
    xft = fitPFFD(fxfp, fpopts);
    %Extract DNA + protein params from this data
    xwlcparams = xft(1:3);
    opts.pwlcg = xft(6);
elseif opts.xwlcfit == 3
    %Use fitPFFDV2: Crop full pull in cropstr fx
    %Crop data in fx
    fxfil = 100;
    fxdat = loadCroppedData(fxfp, 'fx');
    fxx = windowFilter(@mean, fxdat.extension, [], fxfil);
    fxy = windowFilter(@mean, fxdat.force, [], fxfil);
    xft = fitPFFDV2(fxx, fxy, opts.xwlcfrng, opts.xwlcffoldmin, opts.pwlcc );
    xwlcparams = xft(1:3);
    opts.pwlcg = xft(4);
    opts.pwlcc = xft(5);
    opts.Foff = xft(6);
else
    %Guess distance... somehow? lets just use 700nm for now...
    xwlcparams = opts.xwlcguess;
    
end

%Load data crop
if opts.cropstr == -1
    cT = [-1 inf];
else
    cT = loadCrop(opts.cropstr, p, [f e]);
end

%Extract data and apply crop
ki = cd.time > cT(1) & cd.time < cT(2);

frc = double(cd.force(ki)) - opts.Foff;
ext = double(cd.extension(ki));
conpro = (ext - xwlcparams(3) * XWLC(frc, xwlcparams(1), xwlcparams(2))) ./ XWLC( frc, opts.pwlcg, inf ) ;
tsep = double( ext - cd.forceAX(ki) / cd.cal.AX.k + cd.forceBX(ki) / cd.cal.BX.k );

%Split trap sep in two... just take middle of range? findpeaks?
tshalf = ( max(tsep) + min(tsep) )/2 ;

%We just want the jumps, so from below tshalf to above tshalf
ind = find( (tsep(1:end-1) < tshalf) & (tsep(2:end) >= tshalf) );

%Calculate t_low and t_high from the mean durations of low/hi regions
[in, me] = tra2ind(tsep > tshalf);
dw = diff(in);
% Remove ends, which may be not whole
dw = dw(2:end-1);
me = me(2:end-1);
%Average across me == 1 (high force) and ==0 (low force0
tlo = mean( dw( me == 0 ) );
thi = mean( dw( me == 1 ) );
%Get Fs from metadata to convert to time
tlohi = [tlo thi]/cd.opts.Fsamp;


len = length(conpro);
%Extract
nn = length(ind);
for i = nn:-1:1 %Store in struct, so do in reverse
    %Grab section
    tmpind = ind(i) + opts.wid .* [-1 1];
    
    %Just skip this one if it is out of bounds, so we don't have to pad with anything
    if tmpind(1) < 1 || tmpind(2) > len
        continue
    end
    
    ki = tmpind(1):tmpind(2);
    
    %Take median force as a single-value force
    tmpfrc = median(frc(ki));
    
    
    %Extract
    outraw(i).ext    = ext(ki);
    outraw(i).conpro = conpro(ki);
    outraw(i).frc    = tmpfrc;
    outraw(i).frcraw = frc(ki);
end
%Remove empty
ki = arrayfun(@(x) isempty(x.frc), outraw);
outraw = outraw(~ki);

%Actually store as a scalar struct

out.name = f;
out.tlohi = tlohi;
out.ext = {outraw.ext};
out.conpro = {outraw.conpro};
out.frc = [outraw.frc];
out.frcraw = {outraw.frcraw};












