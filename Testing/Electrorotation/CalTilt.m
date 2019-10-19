function out = CalTilt(ined, inOpts)
%Finds the tilt amount from running Step V (adjusting trap stiffness)
% Fits the mean dwell position of each 
%How to deal with outliers?

if nargin < 1
    [f,p] = uigetfile('*.mat');
    pf = [p f];
    ined = load(pf);
    ined = ined.eldata;
end
opts.verbose=1;
opts.vmod = ( (10:-1:1)/10+ 1 )/2; %100:-5:55 pct of v0, the left is just how it's made in LV so easier to ch. here if it changes there
opts.ttrim = [0 inf];

if nargin == 2
    opts = handleOpts(opts, inOpts);
end
%Basic values
Fs = ined.inf.FramerateHz;
parms = procparams(ined.inf);
v0 = parms.v;
npts = Fs/parms.sspd;
pos = parms.pos / 360;

%Adjust for difference between trap position and RotationTracker sign
rot = -ined.rotlong;

%chop into bits: define dwell boundaries
len= length(rot);
indSta = 1:npts:len;
n = length(indSta)-1;

%This should be constant: Remove first bit of first dwell, as bead may be moving into trap
%dws{1} will be of diff length, but that's ok
%...As long as Fs < 5Hz. But I wouldn't use 5Hz
indSta(1) = 0.2*Fs+1; 

%Get voltage each step is at
vs = opts.vmod * v0;
is = mod(0:n-1, length(vs))+1;
vs = vs(is);

%Extract dwells
dws = cell(1,n);
acrs = zeros(1,n);
for i = 1:n
    dws{i} = rot(indSta(i):indSta(i+1)-1);
    %check changing k vs zeta
    [~, acrs(i)] = eracorr(dws{i});
end

%Trim values outside ttrim and with range gt 0.5 (switched trap side)
ki = indSta > opts.ttrim(1)*Fs & indSta < opts.ttrim(2) * Fs;
ki = ki(1:end-1);
rngs = cellfun(@range, dws);
ki2 = rngs < 0.5;
kii = ki & ki2;

%Apply to saved bits
dws = dws(kii);
vs = vs(kii);
acrs = acrs(kii);

mns = cellfun(@mean, dws);
npi = round( (mns - pos) * 2);
mns = mns - npi * 0.5;
phs = ~logical(mod(npi,2));
%choose which trap side has more
if sum(phs) < sum(~phs)
    phs = ~phs;
    pos = mod(pos + 0.5,1);
    mns = mod(mns + 0.5, 1);
end
vs = vs(phs);
mns = mns(phs);

%Handle outliers: Keep within 3*sd
vs0 = vs;
mns0 = mns;
nsd = 4; %Z-score of 3 = 99%, acceptable
while true
    sd = std(mns);
    mn = mean(mns);
    iok = mns < mn + nsd * sd & mn - nsd * sd < mns;
    if all(iok)
        break
    else
        mns = mns(iok);
        vs = vs(iok);
        acrs = acrs(iok);
    end
end

[vs1, mns1] = splitbymodn(vs,mns, 1e3);
[~, acrs1] = splitbymodn(vs,acrs, 1e3); %#ok<ASGLU>

lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';
fitfcn = @(x0,x) x0(1) ./ x + x0(2);

fit = lsqcurvefit(fitfcn, [1 0], vs1, mns1, [], [], lsqopts);
out = mod(fit(2),1) - pos;

if opts.verbose
    figure('Name', sprintf('Tilt %s', ined.inf.Filename(1:end-4)))
    scatter(vs0, mns0, 'MarkerEdgeColor', [.7 .7 .7]), hold on
    set(gca, 'ColorOrderIndex', 1)
    scatter(vs, mns)
    plot(vs1, mns1)
    xx = linspace(vs1(1), vs1(end), 50);
    plot(xx, fitfcn(fit, xx))
%     axis tight
    xl = xlim;
    yl = ylim;
    line(xl, [1 1] * fit(2))
    line(xl, [1 1] * pos + round(fit(2) - pos), 'Color', 'k')
    text(xl(1), mean(yl), sprintf('Offset of %0.2f deg', out * 360))
end






