function reprocessbadcal_resave(infp)

if nargin < 1
    [f, p] = uigetfile('ForceExtension*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        infp = cellfun(@(x) fullfile(p, x), f, 'Un', 0);
    else
        infp = fullfile(p, f);
    end
end

if iscell(infp)
    cellfun(@reprocessbadcal_resave, infp);
end

%Load file
sd = load(infp);
[p, f, e] = fileparts(infp);

%Check if ContourData is a field
if ~isfield(sd, 'ContourData')
    warning('No ContourData found in file %s', f)
    return
end

tmp = sd.ContourData;
%Recalibrate
fns = {'AX' 'BX' };
calnew = tmp.cal;
%Save updated options of lortype 1, Fmax 1e4
calnew.opts.lortype = 1;
calnew.opts.Fmax = 1e4;
calnew.opts.nAlias = 20;
for i = 1:4
    a = calnew.(fns{i});
    %Get the fit data, F and P
    ff = a.F;
    pf = a.P;
    %Crop to 1e4Hz, fit to Lorentzian 
    ki = ff < 1e4;
	ff = ff(ki);
    pf = pf(ki);
    
    %Fit to Lorentzian; taken from @Calibrate
    lb = [0 0 0 15000];
    ub = [50000 10 1e6 1e6];
    Guess = [8000, 0.2, .3, 20000];
    lPbf = log(pf);
    fitfcn = @(x)(log(Lorentzian(x,ff,calnew.opts)) - lPbf);
    options = optimoptions(@lsqnonlin);
    options.Display = 'none';
    fit = lsqnonlin(fitfcn, Guess,lb,ub,calnew.opts);
    %Update cal
    calnew.(fns{i}).fit = fit;
    calnew.(fns{i}).k = 2*pi*calnew.(fns{i}).dC*fit(1);
    calnew.(fns{i}).a = sqrt(calnew.(fns{i}).D/fit(2));
end


% Guess mirror extension
mirext = tmp.extension - tmp.forceAX/tmp.cal.AX.k + tmp.forceBX/tmp.cal.BX.k;
% Recalc extension
tmp.extension = mirext + tmp.forceAX/calnew.AX.k - tmp.forceBX/calnew.BX.k;
%Recalc forces? nah

%Save new cal
tmp.calold = tmp.cal;
tmp.cal = calnew;

%Save some flag to say this happened
tmp.calfix = 'Extension (only) fixed by calfix. Old cal is calold ; forces left unchanged';

%And save
subdir = fullfile(p, 'CalFixed');
if ~exist(subdir, 'dir')
    mkdir(subdir)
end
ContourData = tmp;
save( fullfile(subdir, [f e]) , 'ContourData');

