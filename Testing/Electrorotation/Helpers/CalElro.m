function outcal = CalElro(indat, inopts)

if nargin < 1 ||  isempty(indat)
    [f, p] = uigetfile('*.mat', 'MultiSelect', 'on');
    if ~p
        return
    end
    if iscell(f)
        if nargin > 1
        	outcal = cellfun(@(x) CalElro([p x], inopts), f, 'Un', 0);
        else
            outcal = cellfun(@(x) CalElro([p x]), f, 'Un', 0);
        end
        return
    end
    indat = load([p f]);
    indat = indat.eldata;
end

if ischar(indat)
    indat = readElro_one(indat);
end

opts.nbin = 100; %Pts to bin in powerspec
opts.verbose = 1; %Plot or no
opts.ffit = [.8 1.25] ;% [1 1] + .2 * [-1 1]; %relative force range to use to get Cf_0
opts.kT = .0138 * (273 + 27); %pN nm, 4.14 at 300K
opts.ttrim = [.2  inf]; %Time bounds: trim front bc bead is moving, trim end might be needed for e.g. drift?

if nargin > 1
    opts = handleOpts(opts,inopts);
end

%make sure it's actually a cal file
if ~strcmp(indat.inf.Mode, 'Fixed')
    warning('%s requires Fixed trap data', mfilename)
    outcal = [];
    return
end

%get Cal options
params = procparams(indat.inf.Mode, indat.inf.Parameters);
%Negate rotlong to fix RotTra. Make it between 0 and 1, for simplicity.
indat.rotlong = ceil(max(indat.rotlong))-indat.rotlong;
Fs = indat.inf.FramerateHz;
%Convert to velocity (in rad) with @diff
rv = diff(indat.rotlong*2*pi) * Fs;

%Average together oscillations
npts = Fs / params.modf;
if npts ~= round(npts)
    error('Modulation frequency does not divide sampling frequency')
end
len = length(rv);
oscavg = reshape( rv(1: npts * floor(len/npts)), npts, []);
%Remove first n loops (=~0.2s), since bead might be moving
indsta = ceil(opts.ttrim(1) * params.modf)+1;
%Trim for length, if passed in opts.maxt
indend = min(ceil( opts.ttrim(2)*Fs/npts ), size(oscavg,2));
%Average over the time window
osckeep = oscavg(:,indsta:indend);
oscavg = mean(osckeep, 2)';
oscx = (1:npts) /Fs;
%fit to cosine function
fitfcn = @(x0,x) x0(1)*sin(2*pi*params.modf*x+x0(2))+x0(3);
lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';
fit = lsqcurvefit(fitfcn, [max(oscavg) -pi/4 0], oscx, oscavg, [], [], lsqopts);
% tf = abs(fit(2) > pi/2);
% fit(2) = rem(fit(2), 2*pi);

%Take power spectrum
osckeep = osckeep(:)';
len = length(osckeep);
P = abs(fft(osckeep)).^2 / Fs / (len-1);
F = (0:len-1)/(len-1)*Fs;
%Chop constant term, so it won't be binned
F(1) = [];
P(1) = [];
len = len-1;

%Create bins
binF = (0:opts.nbin:len-1)+1;
%And bin the data
    function outdata = binValues(data)
        lenbin = length(binF)-1;
        outdata = zeros(1,lenbin);
        for ibin = 1:lenbin
            outdata(ibin) = mean(data(binF(ibin):binF(ibin+1)-1));
        end
    end
Fb = binValues(F);
Pb = binValues(P);
%Crop after FNyq
Fnyq = Fs/2;
Pb = Pb(Fb<Fnyq);
Fb = Fb(Fb<Fnyq);


%Get height of power by taking median around the region
%Median should ignore the peak due to the driving, or can just remove that
fitran = opts.ffit * params.modf;
ki = Fb > fitran(1) & Fb < fitran(2);
kp = Pb(ki);
kf = log(Fb(ki));
[~, mi] = max(kp);
kp(mi) = [];
kf(mi) = [];

pf = polyfit(kf, kp, 2);
cf = polyval(pf, log(params.modf));

% cf = median( Pb( Fb > fitran(1) & Fb < fitran(2) ) );

%Calculate k. Units: (pNnm * rad/s) / (rad * (rad/s)^2/Hz ) =  pNnm /radrot
k = 2 * opts.kT * fit(1) * cos(fit(2)) / (params.moda/180*pi) /cf; %pN nm/radian^2

%in VI is : fit(1) * 1/Cf0 * Fs / (moda/360); no cos factor (negl. anyway), 

%Plot
if opts.verbose
    scrsz = get(groot, 'ScreenSize');
    scrsz = scrsz(3:4);
    fg = figure('Position', [scrsz/4 scrsz/2] );
    %plot raw data
    subplot(3,2,[1 2])
    plot(indat.time, indat.rotlong, 'Color', [.7 .7 .7])
    hold on
    plot(smooth(indat.time,41), smooth(indat.rotlong,41), 'Color', [0    0.4470    0.7410])
    axis tight
    mint = opts.ttrim(1);
    maxt = min(opts.ttrim(2), length(indat.rotlong)/Fs);
    xlim([mint, maxt]);
    ht = ( params.pos/360 ) + round( (median(indat.rotlong)-params.pos/360) /.5) * .5;
    line([mint, maxt], ht * [1 1], 'Color', 'k');
    fg.Name = sprintf('Calibration %s, %0.2f deg, %0.1fV^2', indat.inf.Filename, mod(ht,1) * 360, params.v);
    %Display average pos - trap
    lnht = median(indat.rotlong);
    text(mint, sum(ylim .* [.9 .1]), sprintf('Average displacement: %0.3f rad', (lnht - ht)*2*pi ))
    %Plot cos + fit
    subplot(3,2,[3 5])
    cx = (0:100)/100 * npts / Fs;
    plot( cx, fitfcn(fit, cx) )
    hold on
    scatter(oscx, oscavg)
    text(0, mean(ylim), sprintf('%0.2f * sin(2\\pif_0x + %0.2f) + %0.3f', fit))
    %plot pspec fit
    subplot(3,2,[4 6])
    loglog(Fb, Pb)
    hold on
    plot(exp(kf), polyval(pf, kf), 'Color', 'r', 'LineWidth', 1)
    text(Fb(1), geomean(Pb([1 end])), sprintf('C(f_0): %0.2f \n k: %0.2f pNnm/rad^2', cf, k))
    axis tight
end

%Output data
outcal.params = params;
outcal.k = k;
outcal.cf = cf;
outcal.cosfit = fit;
outcal.calopts = opts;
outcal.Fb = Fb;
outcal.Pb = Pb;

end
