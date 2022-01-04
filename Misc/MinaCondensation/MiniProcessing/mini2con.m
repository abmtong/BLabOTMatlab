function outfit = mini2con(infp, inOpts)
%Tranforms minitweezers data to contour
%Expects a file with F-X curves and data in one file,
% with F-X curves contained within cropstring 'fx'

%I think mini data doesn't add the bead extension, but that should be 'absorbed' into SM, since they're both springs.
% Need to calculate extension offset

%OR since we're doing per-trace, just fit the f-x to a nth-poly and use that? hmm dont get offset though unless I assume some things

dnalen = 6256; %DNA length, for XWLC fitting

opts.fil=50; %XWLC fit filter (dsamp)

%fitForceExt opts
%Cutoff forces, for fitting
opts.loF = 1; %Not all pulling curves go this low, unfortunately. Will make do?
opts.hiF = 20; %Some fit funny ? like they get stiffer at high F? Maybe Mini rolloff is different. Just need to cover ~1=15pN
%Guess for fitting: [ PL(nm) SM(pN) CL(bp) Off(nm) Off(F) ]
opts.x0 = [20 200 dnalen -1500 0]; %Empirical offset guess
%Fitting bounds
opts.lb = [0   0   dnalen -1e4 -0];
opts.ub = [1e3 1e4 dnalen  1e4  0];%Fits look better with F offset [of course], but theoretically mini should have very precise F?

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

if nargin < 1
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~iscell(f)
        f = {f};
    end
    outfit = cellfun(@(x) mini2con(fullfile(p, x), opts), f, 'Un', 0);
    return
end

%Fileparts
[p, f, e] = fileparts(infp);
f = [f e];

%Load
sd = load(infp);
sd = sd.stepdata;

%Loadcrop, use cropstring 'fx'
cropT = loadCrop('fx', p, f);
if isempty(cropT)
    outfit = [];
    return
end

%Extract values
tim = sd.time{1};
frc = sd.force{1};
ext = sd.contour{1};

ki = sd.time{1} > cropT(1) & sd.time{1} < cropT(2);
ffrc = windowFilter(@mean, frc(ki), [], opts.fil);
fext = windowFilter(@mean, ext(ki), [], opts.fil);
ffrc = abs(ffrc);
%Sort, to keep all pulls?
[ffrc, si] = sort(ffrc);
fext = fext(si);

%Fit to WLC, fitting P/S/x0
[fit, fitfcn] = fitForceExt( fext, ffrc, opts, 1 );

%Not great, but fitForceExt pops a fig, let's rename it
fig = gcf;
fig.Name = f;

%Convert extension data to contour data
frc = frc - fit(5); %Apply force offset
ext = ext - fit(4); %Apply ext offset
con = ext ./ XWLC(frc, fit(1), fit(2)) / 0.34; %Convert to contour

%Create output struct
stepdata = struct('time', {{tim(:)'-tim(1)}}, 'extension', {{ext(:)'}}, 'contour',{{con(:)'}}, 'force', {{frc(:)'}}); 

%Store the f-x fit in the offset field?
off.MX = ffrc; %Frc data
off.AX = fext; %Ext data
off.BX = fitfcn(fit, ffrc); %Ext fit
off.AY = nan(size(ffrc)); %Redundant
off.BY = nan(size(ffrc)); %Redundant
stepdata.off = off; %#ok<STRNU>

%Resave, in subfolder mini2con
subfol = 'mini2con';
if ~exist(fullfile(p, subfol), 'dir')
    mkdir(p, subfol)
end
save(fullfile(p, subfol, f), 'stepdata')

outfit = fit;




