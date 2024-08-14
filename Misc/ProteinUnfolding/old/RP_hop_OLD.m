function out = RP_hop(infp, inOpts)

%RP for 'hopping passive data'
%Would RP_passive just work for this? maybe? Probably better to not...

%WLC fitting per-pull
opts.xwlcfit = 1; %Do fitting. Set 0 to use backup 
opts.cropstrfx = 'fx'; %Crop string for initial pulling curve. DNA only.
opts.xwlcfil = 30; %Filter and downsample XWLC pull by this much
opts.xwlcguess = [50 900 700]; %XWLC guess / fallback

opts.cropstr = ''; %Crop string for hopping data
opts.ysd = 1; %SD of KDF to estimate well position. Increase if wells arent being separated

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


if nargin < 1
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        out = cellfun(@(x) RP_hop(fullfile(p,x)), f, 'Un', 0);
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
if opts.xwlcfit
    %Load crop
    xcT = loadCrop(opts.cropstrfx, p, [f e]);
    
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
    xft = lsqcurvefit(fitfcn, opts.xwlcguess, double(xext), double(xfrc), [0 0 0], [inf inf inf], oop);
    
    xwlcparams = xft;
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

frc = double(cd.force(ki));
ext = double(cd.extension(ki));
tim = double(cd.time(ki));

%Create mirror position channel
mirext = cd.extension - cd.forceAX / cd.cal.AX.k + cd.forceBX / cd.cal.BX.k;
mirext = double(mirext(ki));

%Mirror extension channel should be a two-state hopper. Create kdf and find two major peaks with @findpeaks
[p,x] = kdf(mirext, .01, opts.ysd); 
[pkht, pkloc] = findpeaks(p,x);

%Sort by height, take top two locs
[~, si] = sort(pkht, 'descend');
pkloc = pkloc(si);

mu = sort( pkloc(1:2) );

%Divide by crossing the midpt. 1 = low state, 2 = high state
state = sign( mirext - mean(mu) );% Becomes [-1, 1]
state = (state + 1) /2 +1; %[-1, 1] > [1, 2]

%And split
[ind, mea] = tra2ind(state);
extsegs = arrayfun(@(x,y) ext( x:y-1 ), ind(1:end-1), ind(2:end), 'Un', 0);
frcsegs = arrayfun(@(x,y) frc( x:y-1 ), ind(1:end-1), ind(2:end), 'Un', 0);
timsegs = arrayfun(@(x,y) tim( x:y-1 ), ind(1:end-1), ind(2:end), 'Un', 0);
%Divide by pos.
extsegs = { extsegs( mea == 1 ) extsegs( mea == 2 ) };
frcsegs = { frcsegs( mea == 1 ) frcsegs( mea == 2 ) };
timsegs = { timsegs( mea == 1 ) timsegs( mea == 2 ) };

%Divide U and F wells for each state. Same method, findpeaks
mus = cell(1,2);
for i = 1:2
    [p,x] = kdf([extsegs{i}{:}], .01, opts.ysd);
    [pkht, pkloc] = findpeaks(p,x);
    [~, si] = sort(pkht, 'descend');
    pkloc = pkloc(si);
    mu = sort(pkloc(1:2));
    
    %Maybe check that length(pkloc) >= 2...
    
    mus{i} = mu;
    
    
    
end








