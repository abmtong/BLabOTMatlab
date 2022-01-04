function out = mina2con(inpf)
%Calculates contour from extension
% Works by fitting a F-Xcurve in the file, or by guessing offset+XWLC params
% Minis don't calculate bead position, so PL/SM numbers won't mean anything, but the shape does fit nicely
%  It's like the F axis is tilted, i.e. no longer orthogonal but still linearly independent

%TO CHANGE: Actually we should set P and fit an alpha to get that P, if we actually want to get bead extension / CL

%DNA length [hard coded]
dnalen = 6200*.34;
ffitrng = [1.5 25];
%fit this to XWLC with contour = 6.2kb
xmeth = 3;
    
if nargin < 1
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if iscell(f)
        cellfun(@(x)mina2con(fullfile(p,x)), f)
        return
    else
        inpf = [p f];
    end
end

%Format filename
[path, f, e] = fileparts(inpf);
file = [f e];

%Load file
sd = load(fullfile(path, file));
sd = sd.stepdata;
%Extract parts
if isfield(sd, 'extension')
    ext = sd.extension{1};
    iscon = 0;
else
    ext = sd.contour{1};
    iscon = 1;
end
frc = sd.force{1};

ft = [10 125 prctile(ext(frc>10&frc<20),95)-dnalen]; %Default fit

%Use "fx" crop field to find a f-x curve
cropt = loadCrop('fx', path, file);
if isempty(cropt)
    warning('No cropfx found for %s, using default %0.2fnm/%0.2fpN', file, ft(1), ft(2))
else
    %Get the coordinates
    fxsd = cropstepdata(sd, cropt, 0);
    if iscon
        cext = fxsd.contour{1};
    else
        cext = fxsd.extension{1};
    end
    cfrc = fxsd.force{1};
    
    extsm = windowFilter(@mean, cext, [], 10);
    frcsm = windowFilter(@mean, cfrc, [], 10);
    
    ki = frcsm > ffitrng(1) & frcsm < ffitrng(2);
    
    %ext = bead ex - F * alpha * 2
    fitfcn = @(x0,x) XWLC(x, x0(1), x0(2), [], xmeth) * dnalen; %ext(F)
    lb = [0 0 -inf];
    xg = ft;
    xg(3) = median(extsm(frcsm > 13 & frcsm < 17))-dnalen;
    ub = [100 2000 inf];
    
    ft = lsqcurvefit(@(a,b)fitfcn(a,b)+a(3), xg, frcsm(ki), extsm(ki), [], [], optimoptions('lsqcurvefit', 'Display', 'none'));
    figure('Name', sprintf('mina2con, file:%s', file))
    plot(extsm-ft(3), frcsm), hold on, plot(fitfcn(ft, frcsm), frcsm)
end

%And then convert the rest of the trace to nm contour
con = (ext - ft(3))./XWLC(frc, ft(1), ft(2),[],xmeth);

if iscon
    sd.extension = sd.contour;
end
sd.contour = {con};

%Save XWLC info to file
out = sd;
xwlcopts.cropt = cropt;
xwlcopts.params = ft;
xwlcopts.xwlcmethod = xmeth;
out.xlwcopts = xwlcopts;

fprintf('File %s converted to contour (XWLC=%0.2fnm/%0.2fpN/%0.1fnm)\n', f, ft(1), ft(2), ft(3))
%Save over
stepdata = out;
save(fullfile(path, file), 'stepdata')
