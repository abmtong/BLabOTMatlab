function out = RPzerohopp1(infp, varargin)

%RP for '0 force jump' data
%Like RPhop but care less about unfolding time, just split by trap sep
% Doing some shortcuts that only works if this is timeshared data (i.e. trap sep is pretty exact)

opts.wid = [5 1000]; %Grab this neighborhood around transitions. Grab more for 'safety', plot less later

opts.nonhypotforce = 0; %Use non-hypot force (i.e. (fBX - fAX)/2 instead of abs( Fx^2 + Fy^2 ) ), as this can skew low forces at high Fs

%WLC fitting per-pull
opts.xwlcfit = 3; %Do fitting. Set 0 to use backup, 2 for fitPFFD, 1 for just DNA crop
opts.otherfxdata = 0; %Data for pull is from a separate file
opts.cropstrfx = 'fx'; %Crop string for initial pulling curve
opts.xwlcfil = 30; %Filter and downsample XWLC pull by this much
opts.xwlcguess = [50 900 700]; %XWLC guess / fallback
opts.xwlcfrng = [1.5 30]; %XWLC fit range
opts.xwlcffoldmin = 4; %Unfolding force minimum for rip detection: try 4 unless the protein unfolds lower

opts.cropstr = {'1' '2'}; %Crop string for hopping data. Use cell for batch processing
opts.pwlcc = 104 * 0.35; %Protein contour length, only if xwlcfit >= 2

opts.Foff = 0; %Force offset, set or obtained from XWLC fit (if allowed)

opts.verbosefit = 1; %Plot fit

if nargin > 1
    opts = handleOpts(opts, varargin);
end


if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        out = cellfun(@(x) RPzerohopp1(fullfile(p,x), varargin{:}), f, 'Un', 0);
        out = [out{:}]; %Could try to reshape this, but every trace might not have every condition, and empties get nuked by [{:}]
%         ncrp = length(out{1});
%         out = reshape( [out{:}] , ncrp, [] )';
        return
    end
    infp = fullfile(p,f);
end

if iscell(opts.cropstr)
    len = length(opts.cropstr);
    tmpout = cell(1,len);
    for i = 1:len
        %This will show the fitting multiple times if opts.verbosefit, turn it off for others...?
        if i == 2
            opts.verbosefit = 0;
        end
        tmpout{i} = RPzerohopp1(infp, setfield(opts, 'cropstr',  opts.cropstr{i})) ;
    end
    tmpout = [tmpout{:}];
    out = tmpout;
    return
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
    
    if opts.nonhypotforce
        xfrc = ( cd.forceBX(ki) - cd.forceAX(ki) )/2; %Recalc force as BX-AX /2. May lead to negative forces which may warn in @XWLC
    else
        xfrc = cd.force(ki);
    end
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
    if isempty(fxdat)
        out = [];
        return
    end
    if opts.nonhypotforce
        fxy = windowFilter(@mean, (fxdat.forceBX - fxdat.forceAX) /2, [], fxfil); %Recalc force as BX-AX /2. May lead to negative forces which may warn in @XWLC
    else
        fxy = windowFilter(@mean, fxdat.force, [], fxfil);
    end
    fxx = windowFilter(@mean, fxdat.extension, [], fxfil);
    
    fxx = double(fxx);
    fxy = double(fxy);
    
    [xft, ftdat] = fitPFFDV2(fxx, fxy, opts.xwlcfrng, opts.xwlcffoldmin, opts.pwlcc );
    xwlcparams = xft(1:3);
    opts.pwlcg = xft(4);
    opts.pwlcc = xft(5);
    opts.Foff = xft(6);
    
    %Plot
    if opts.verbosefit
        figure('Name', sprintf('RPzhp1: %s', f))
        hold on
        plot(fxx, fxy)
        plot(ftdat(:,1), ftdat(:,2))
        %Add fit txt
        txtind = find( fxy > max(fxy)/2, 1, 'first');
        text( (fxx(txtind)), (fxy(txtind)), sprintf('PL: %0.2f, SM:%0.2f, CL: %0.2f\n pPL: %0.2f, pCL: %0.2f', xwlcparams(1), xwlcparams(2), xwlcparams(3), opts.pwlcg, opts.pwlcc), 'HorizontalAlignment', 'right')
    end
    
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
if isempty(cT)
    out = [];
    return
end

%Extract data and apply crop
ki = cd.time > cT(1) & cd.time < cT(2);

if opts.nonhypotforce
    frc = double(cd.forceBX(ki) - cd.forceAX(ki))/2 - opts.Foff; %Recalc force as BX-AX /2. May lead to negative forces which may warn in @XWLC
else
    frc = double(cd.force(ki)) - opts.Foff;
end

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
    outraw(i).xwlcft = [xwlcparams opts.pwlcg opts.pwlcc opts.Foff];
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
out.xwlcft = {outraw.xwlcft};












