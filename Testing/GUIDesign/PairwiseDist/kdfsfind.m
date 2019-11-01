function [pkloc, ssz, histfit] = kdfsfind(incon, varargin)
%Find steps using the 'kdf' method: Find peak location by looking at kdf


%Handle NVPs. This is called length(incon)+1 unnecessary times, but is fast anyway
ip = inputParser;
addRequired(ip, 'incon');
addParameter(ip, 'fpre', {10,1}); %pre filter
addParameter(ip, 'binsz', 0.1); %bin size, for kdf and hist
addParameter(ip, 'kdfsd', 1); %kdf gaussian sd
addParameter(ip, 'histdec', 2); %Step histogram decimation factor
addParameter(ip, 'histfil', 5); %Filter width for step histogram
addParameter(ip, 'kdfmpp', .5); %Multiplier to kdf MinPeakProminence
addParameter(ip, 'histfitx', [0 15]); %X range to fit histfit to
parse(ip, incon, varargin{:});

fpre = ip.Results.fpre;
binsz = ip.Results.binsz;
kdfsd = ip.Results.kdfsd;
histdec = ip.Results.histdec;
histfil = ip.Results.histfil;
kdfmpp = ip.Results.kdfmpp;
histfitx = ip.Results.histfitx;

%Generating fit requires batch operation, so send into batch mode if not
if nargout > 2 && ~iscell(incon)
    incon = {incon};
end

%If first input is cell, batch process
if iscell(incon)
    [pkloc, ssz] = cellfun(@(x) kdfsfind(x, varargin{:}),incon,'Un',0);
    ssz = [ssz{:}];
    %Fit the step size distribution to a gaussian, calculate M+-SEM
    %Get histogram
    [~, xx, ~, yy] = nhistc(ssz, binsz);
    %Decimate by histdec
    %Crop xx, yy length to an integer mult. of histdec, then avg/sum across
    % May chop the last few values, w/e
    np = floor(length(xx)/histdec)*histdec;
    xx = mean(reshape(xx(1:np), histdec, [] ), 1);
    yy =  sum(reshape(yy(1:np), histdec, [] ), 1);
    %Fit the resulting histogram to a gaussian
    xki = xx>histfitx(1) & xx<histfitx(2);
    yy = smooth(yy, histfil)';
    %Fit to a single gaussian
    fitfcn = @(x0,x) x0(1) * normpdf(x,x0(2),x0(3));
    xg = [max(yy)*sqrt(2*pi*3^2), 10, 3];
    %Fit to two gaussians
%     fitfcn = @(x0,x) x0(1) * normpdf(x,x0(2),x0(3)) + x0(4) * normpdf(x,x0(2)*2,x0(3)*2);
%     xg = [max(yy), 10, 3, max(yy)/2];
    gfit = lsqcurvefit(fitfcn,xg, xx(xki), yy(xki),[],[],optimoptions('lsqcurvefit', 'Display', 'None'));
    
%     gfit = fitgauss_iter(xx,yy,[-2 0]));
    
    %And plot
    figure('Name', sprintf('KDFsfind: Data %s, Filter: %d/%d, KDF [sd, mpp] [%0.1f, %0.2f]', inputname(1), fpre{:}, kdfsd, kdfmpp))
    plot(xx,yy), hold on
    plot(xx, fitfcn(gfit,xx))
    xlim([0 30])
    [ymx, ymxi] = max(yy);
    %N is fit(1)/binsz, print mean +- sem
    text(xx(ymxi), ymx*1.1,sprintf('%0.2f +- %0.2f, est. %0.2f%% good steps\n', gfit(2), gfit(3)/sqrt(gfit(1)/binsz/histdec), gfit(1)/binsz/histdec/length(ssz)*100))
    histfit.fit = gfit;
    histfit.x = xx;
    histfit.y = yy;
    return
end

%Filter with fpre
incon = windowFilter(@mean, incon, fpre{:});
%Calculate kdf
[histy, histxx] = kdf(incon, binsz, kdfsd);

%Set MinPeakProminence to be a multiple of the median peak difference [arbitrary, default 1/2]
% Maybe setting a prctile cutoff instead of kdfmpp would be better?
pkhei = findpeaks(double(histy), double(histxx));
trhei = findpeaks(-double(histy), double(histxx));

medpk = median(pkhei);
medtr = -median(trhei);
mpp = (medpk - medtr) * kdfmpp;
[~, pkloc] = findpeaks(double(histy), double(histxx), 'MinPeakProminence', mpp);

ssz = diff(pkloc);

%Can I find dwells?
%...could HMM this I guess, with lc as steps
% Or could KV this with known nsteps? accept if they overlap? Ghe-like