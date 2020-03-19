function out = jp2con(inpf, xwlcps)
%Calculates contour from extension
% Works by fitting a F-Xcurve in the file
% xwlcps = [PL(nm), SM(pN), CL(bp) OffX(nm) OffF(pN)]

%Options to edit
dnalen = 1200; %DNA length (nm, as a guess)
fitopts.x0 = [50 900 dnalen 0 0]; %Fit guess, [PL SM CL offsetX offsetF]
fitopts.lb = [ 0   0   0  0 -1]; %Lower bound
fitopts.ub = [1e3 1e4 inf 0 1]; %Upper bound
fitopts.loF = 1; %Force fit range, pN
fitopts.hiF = 30;

if nargin < 1 || isempty(inpf)
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if iscell(f)
        cellfun(@(x)jp2con(fullfile(p,x)), f)
        return
    else
        inpf = [p f];
    end
end

%Format filename
[path, f, e] = fileparts(inpf);
file = [f e];

%Load file. Will be f-x
sd = load(fullfile(path, file));
sd = sd.ContourData;
%Extract parts
ext = sd.extension;
frc = sd.force;
tim = sd.time;

if nargin < 2
    %Use "fx" crop field to find a f-x curve
    cropt = loadCrop('fx', path, file);
    if isempty(cropt)
        error('No cropfx found for %s', file)
    else
        %Get the coordinates
        cext = ext(tim > cropt(1) & tim < cropt(2) );
        cfrc = frc(tim > cropt(1) & tim < cropt(2) );
        %Smooth
        extsm = windowFilter(@mean, cext, [], 25);
        frcsm = windowFilter(@mean, cfrc, [], 25);
        %Crop to force range
        ki = frcsm > fitopts.loF & frcsm < fitopts.hiF;
        %Fit to XWLC
        %     fitopts.ub(5) = min(frcsm(ki));
        [ft, fitfcn] = fitForceExt(extsm(ki), frcsm(ki), fitopts, 0);
        
        figure('Name', sprintf('mina2con, file:%s', file))
        plot(extsm, frcsm), hold on, plot(fitfcn(ft, frcsm), frcsm)
    end
else %Use passed values
    ft = xwlcps;
    cropt = 0;
end
%Convert the rest of the trace to contour (nm)
con = (ext - ft(4))./XWLC(abs(frc - ft(5)), ft(1), ft(2),[],3);

%Save XWLC info to file
out = sd;
out.forceAX = {out.forceAX};
out.forceAY = {out.forceAY};
out.forceBX = {out.forceBX};
out.forceBY = {out.forceBY};
out.extension = {out.extension};
out.force = {out.force};
out.contour = {con};
out.time = {out.time};

xwlcopts.cropt = cropt;
xwlcopts.params = ft;
out.xlwcopts = xwlcopts;

fprintf('File %s converted to contour (XWLC=%0.2fnm/%0.2fpN/%0.1fpN)\n', f, ft(1), ft(2), ft(5))
%Save over
stepdata = out;
save(fullfile(path, ['phage' file]), 'stepdata')
