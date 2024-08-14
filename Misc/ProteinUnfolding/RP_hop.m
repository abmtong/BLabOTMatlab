function out = RP_hop(infp, inOpts)

%RP for 'hopping passive data'
%Would RP_passive just work for this? maybe? Probably better to not...

%WLC fitting per-pull
opts.xwlcfit = 2; %Do fitting. Set 0 to use backup, 2 for fitPFFD, 1 for just DNA crop
opts.cropstrfx = 'fx'; %Crop string for initial pulling curve. DNA only.
opts.xwlcfil = 30; %Filter and downsample XWLC pull by this much
opts.xwlcguess = [50 900 700]; %XWLC guess / fallback

opts.cropstr = ''; %Crop string for hopping data
opts.ysd = 1; %SD of KDF to estimate well position. Increase if wells arent being separated
opts.fil = 10; %Filter amt
opts.pwlcg = 0.4; %Protein persistence length
opts.pwlcc = 93 * 0.35; %Protein contour length, only if xwlcfit == 2
opts.minjump = 100; %Minimum state duration, see code
opts.edgetrim = 1e3;%Pts to trim from edges, to account for mirror movement. Decent value is 20ms * Fsamp ?

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
if opts.xwlcfit == 1
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
    xft = lsqcurvefit(fitfcn, opts.xwlcguess, double(xfrc), double(xext), [0 0 0], [inf inf inf], oop);
    
    xwlcparams = xft;
elseif opts.xwlcfit == 2
    %Use fitPFFD
    fpopts = struct('pwlcc', opts.pwlcc, 'dsamp', opts.xwlcfil, 'pwlcg', opts.pwlcg);
    xft = fitPFFD(infp, fpopts);
    %Extract DNA + protein params from this data
    xwlcparams = xft(1:3);
    opts.pwlcg = xft(6);
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


%Break this data into four quadrants, mirror [low high] x [folded unfolded]
% X vs F data should have four wells

%Filter data
frcf = windowFilter(@median, frc, opts.fil, 1);
extf = windowFilter(@median, ext, opts.fil, 1);
pro = ext - xwlcparams(3) * XWLC(frcf, xwlcparams(1), xwlcparams(2));
%Subtract DNA WLC to make this closer to simple quadrants

%Convert to protein contour
procon = pro ./ XWLC(frcf, opts.pwlcg, inf);
proconf = windowFilter(@mean, procon, opts.fil, 1);

%Find dividing lines in con and frc space: kdf, take valley with most prominence?
[fp, fx] = kdf(frcf, 0.1, 1);
[~, fpx, ~, fpp] = findpeaks(-fp, fx);
%Take highest prominence peak
[~, maxi] = max(fpp);
fmid = fpx(maxi);

[pp, px] = kdf(proconf, 0.1, 1);
[~, ppx, ~, ppp] = findpeaks(-pp, px);
[~, maxi] = max(ppp);
pmid = ppx(maxi);

%Divide data by 'quadrant' : 1 + 2* (f > fmid) + (p > pmid); 
%^ 3 4 Hi
%f 1 2 Lo
%  p >
%  F U
% i.e., 1/2 is low force, waiting to fold (2 > 1), 3/4 is high force, waiting to unfold (3 > 4)
% Cycle is [when all transitions happen] 2>1>3>4>2
st = 1 + 2* (frcf > fmid) + (proconf > pmid);
%Median filter to remove jumps
stf = windowFilter(@median, st, opts.minjump, 1);

%Crop like it's a pulling cycle, so crop at lo>hi force jump, i.e. 1/2 -> 3/4
% ...Or just crop by frc > fmid
fhi = frcf > fmid;
ind = find([0 fhi]==0 & [fhi 0] == 1);

%And divide
len = length(ind)-1;
for i = len:-1:1;
    %Create pts
    ki = ind(i) + opts.edgetrim : ind(i+1) - opts.edgetrim;
    
    if isempty(ki)
        continue
    end
    
    out(i).frc    = frc(ki);
    out(i).ext    = ext(ki);
    out(i).conpro = procon(ki);
    
    %Get state vector for this snippet
    tmp = stf(ki);
    
    %Set the 'retract' index as the hi>lo jump
    tmp2 = fhi(ki);
    out(i).retind = find(tmp2 == 0, 1, 'first');
    
    %Look for un/folding events: 2>1 and 3>4
    [in, me] = tra2ind(tmp);
    irip = strfind(me, [3 4]);
    % First check that it unfolds at all: the end is 4
    if tmp( out(i).retind -1 ) == 4 && ~isempty(irip)
        out(i).ripind = in(1+ irip(end));
    else
        out(i).ripind = [];
    end
    
    iref = strfind(me, [2 1]);
    if tmp( end ) == 1 && ~isempty(iref)
        out(i).refind = in(1+ iref(end));
    else
        out(i).refind = [];
    end
end

%Remove empty
ki = arrayfun(@(x) isempty(x.frc), out);
out = out(~ki);

%Output to a struct








