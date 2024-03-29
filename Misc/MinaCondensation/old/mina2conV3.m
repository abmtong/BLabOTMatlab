function out = mina2conV3(inpf)
%Calculates contour from extension
% Fits a F-Xcurve in the file, sets k such that PL matches some preset value

%V3: Use high force to set k such that SM = 1200

%Outdated: try mini2con

dnalen = 6200*.34; %nm, DNA length
ffitrng = [1.5 inf]; %pN, force fit range
xmeth = 3; %XWLC method, doesn't really matter
xp = 50; %nm, persistence length
strmod = 1200; %pN, stretch mod
fmid = 30; %Above is 'high force'

%Hmm this doesn't really work, probs still too many free var.s
% 

%If no input, select files; process all if multiple selected
if nargin < 1
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
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



%Use "fx" crop field to find a f-x curve
cropt = loadCrop('fx', path, file);
if isempty(cropt)
    warning('No cropfx found for %s, skipping', file)
    return
else
    %Get the coordinates
    fxsd = cropstepdata(sd, cropt, 0);
    if iscon
        cext = fxsd.contour{1};
    else
        cext = fxsd.extension{1};
    end
    cfrc = fxsd.force{1};
    
    %Calculate k such that SM matches
    kism = cfrc > fmid & cfrc < ffitrng(2);
    hidat = polyfit(cext(kism), cfrc(kism),1);
    hitheo = strmod / dnalen; %= SM/CL
    kap = ((hidat(1)^-1 - hitheo^-1 )/2 )^-1; %/2 since there's 2 traps
    
    extsm = windowFilter(@mean, cext, [], 25);
    frcsm = windowFilter(@mean, cfrc, [], 25);
    
    ki = frcsm > ffitrng(1) & frcsm < ffitrng(2);
    
    extsm = extsm - frcsm / kap * 2;
    
    % PL SM CL Xoff ka Foff
    xg = [xp  strmod dnalen    0 kap 0]; %Default fit
    lb = [  0      0 dnalen -inf kap -1];
    ub = [1e3    1e4 dnalen  inf kap min(frc)];
    
    %Trap ext = tether ext + F * alpha * 2 - offset
    fitfcn = @(x0,x) XWLC(x-x0(6), x0(1), x0(2), [], xmeth) * x0(3) - x0(4);% + x / x0(5) * 2; %bead ext(F)
    xg(4) = -(median(extsm(frcsm > 13 & frcsm < 17))-dnalen);
    
    xfit = lsqcurvefit(fitfcn, xg, frcsm(ki), extsm(ki), lb, ub, optimoptions('lsqcurvefit', 'Display', 'none'));
    figure('Name', sprintf('mina2con, file:%s', file))
    plot(extsm+ xfit(4), frcsm), hold on, plot(fitfcn(xfit, frcsm)+ xfit(4), frcsm)
end

%And then convert the rest of the trace to nm contour
con = (ext + xfit(4) - xfit(5)*abs(frc-xfit(6)))./XWLC(abs(frc-xfit(6)), xfit(1), xfit(2),[],xmeth);

if iscon
    sd.extension = sd.contour;
end
sd.contour = {con};

%Save XWLC info to file
out = sd;
xwlcopts.cropt = cropt;
xwlcopts.params = xfit;
xwlcopts.xwlcmethod = xmeth;
out.xlwcopts = xwlcopts;

fprintf('File %s converted to contour (XWLC=%0.2fnm/%0.2fpN/%0.1fnm, XFoff = (%0.1f, %0.3f), k = %0.4fpN/nm)\n', f, xfit([1 2 3 4 6 5]))
%Save over
stepdata = out; %#ok<NASGU>
save(fullfile(path, file), 'stepdata')
