function [PFV, tf, pslen] = polpause(ext, sgfpcell, samp, xwlcpcell)

if ~isa(ext, 'double')
    ext = double(ext);
end

if nargin<2
    sgfpcell = {1 133};
elseif ~iscell(sgfpcell)
    sgfpcell = arrayfun(@(x) x, sgfpcell, 'Uni', 0);
end

if nargin < 3
%     samp = [4e3/3 13]; %Input frq, dsamp factor - wee
    samp = [800 1]; %input frq, dsamp factor - wx
end

if nargin < 4
    xwlcpcell = {12 30 1200 .34}; %F PL SM nm/bp
elseif ~iscell(xwlcpcell)
    xwlcpcell = arrayfun(@(x) x, xwlcpcell, 'Uni', 0);
end

binsz = 0.1;

%Define sgolay filter
[~, sgf] = sgolay(sgfpcell{:}); %We want the differential matrix only
%Downsample
ext = windowFilter(@mean, ext, [], samp(2));
if length(xwlcpcell{1}) > 1 %also dsamp force if it's a cell
    xwlcpcell{1} = windowFilter(@mean, xwlcpcell{1}, [], samp(2));
end
%Shift to zero
ext = ext - min(ext);
%Convert to contour (bp)
ext = ext ./ XWLC(xwlcpcell{:}) / .34;
%Filter
extF  = conv(ext, flipud(sgf(:,1)), 'same'); %Might make more sense to xcorr(u, v) instead of conv(u, flipud(v)), but is the same
if sgfpcell{1} == 0 %0 rank doesn't generate d matrix
    dextF = [0 conv(diff(extF), flipud(sgf(:,1)),'same')];
    fwid = 2*(size(sgf, 1) - 1) / 2;
else
    dextF = conv(ext, flipud(sgf(:,2)), 'same');
    fwid = (size(sgf, 1) - 1) / 2;
end
%Crop start and end, because edge effects of @conv (and I don't have the transients for first derivative)
ext =     ext( 1 + fwid : end - fwid );
extF =   extF( 1 + fwid : end - fwid );
dextF = dextF( 1 + fwid : end - fwid ) * samp(1) / samp(2) ; %convert rate from bp/pt to bp/s

%Make histogram
bins = floor(min(dextF)/binsz)*binsz:binsz:ceil(max(dextF)/binsz)*binsz;
vbin =histcounts(dextF, bins);
bincents = (bins(1:end-1) + bins(2:end))/2;
figure, bar(bincents, vbin)

method = 3;
if method == 1
    %Fit a gaussian to the pause population: those where velocity < velocity threshold
    vthrg = .5;
    dextFc = dextF( abs(dextF) < vthrg );
    nc = length(dextFc);
    gs = fitdist(dextFc(:), 'normal');
    gsy = pdf(gs, bins) * nc * mean(diff(bins));
    hold on, plot(bins, gsy)
    mu = gs.mu;
elseif method == 2
    %Fit a gaussian to the pause pop: gauss centered at 0, fit to LHS
    vthrg = 0;
    vc = vbin(bincents <= vthrg);
    xc = bincents(bincents <= vthrg);
    lsqopts = optimoptions('lsqcurvefit', 'Display', 'none');
    fitfcn = @(x0,x)x0(1)*normpdf(x,0,x0(2));
    ft = lsqcurvefit(fitfcn, [max(vc)*6,std(vc)], xc, vc, [],[],lsqopts);
    mu = 0;
    fty = fitfcn(ft, bincents);
    hold on, plot(bincents, fty)
elseif method == 3
    %Fit a gaussian centered at 0 (pause) and one pos (tloc)
    fitfcn = @(x0,x) x0(1) * normpdf(x,0,x0(2)) + x0(3) * normpdf(x,x0(4),x0(5));
    gu = [max(vbin)*6, std(vbin), max(vbin), prctile(vbin, 90), std(vbin)];
    ft = lsqcurvefit(fitfcn, gu, bincents, vbin);
    hold on, plot(bincents, fitfcn(ft, bincents))
    plot(bincents, normpdf(bincents, 0, ft(2))*ft(1))
    plot(bincents, normpdf(bincents, ft(4),ft(5))*ft(3))
    text( 0, ft(1)/ft(2)/sqrt(2*pi), sprintf('Pause peak: Mean %0.2f, SD %0.2f, Time %0.2f%%', 0, ft(2), 100*ft(1)/(ft(3)+ft(1))))
    text( ft(4), ft(3)/ft(5)/sqrt(2*pi), sprintf('Tloc peak: Mean %0.2f, SD %0.2f, Time %0.2f%%', ft(4), ft(5),100* ft(3)/(ft(3)+ft(1))))
    mu=0;
end


%Take the sum of the LHS of the gaussian, and double this to get the integral of the gaussian

pausesLHS = dextF(dextF < mu);
pausesRHS = 2*mu - pausesLHS;
pauses = [pausesLHS pausesRHS];
PFV = (sum(dextF) - sum(pauses)) / ( length(dextF) - length(pauses) );
%Calculate pause probability histogram by comparing non-paused to pause histogram
%Define bins, center about mu now
posbins = bins(bins >= 0) + mu;
%These are the rates > mu
histposcts = histcounts( dextF(dextF > mu) , posbins);
histpospause = histcounts( pausesRHS, posbins);
%The probability a given rate comes from a pause
probpause = histpospause./histposcts;
%Debug
posbinsplot = ( posbins(1:end-1) + posbins(2:end) )/2;
figure, plot(posbinsplot, histposcts/max(histposcts)), hold on,  plot(posbinsplot, histpospause/max(histpospause)), plot(posbinsplot, probpause)
%Remove 1/0s and 0/0s
keepind = isfinite(probpause);
%Interp the missing values
histprobpause = interp1(posbins(keepind), probpause(keepind), posbins);
%We're thr sure it's in a pause if the rate < vthr, gotten from histprobpause
thr = 0.95;
vplus = posbins(1:end-1);
vplus = vplus(histprobpause > thr);
vthr = max(vplus) + mean(diff(posbins))/2; %Add to the end of the bin, half of binsize
%Find pauses
%Check pause status for every pt
ind =  diff(dextF < vthr);
%Extract pause starts and ends, taken from @ProcessOneData
indSta = find(ind>0); %=+1, start of pause
indEnd = find(ind<0); %=-1, end of pause
%Might need to add pts at 1 or end, depending on whether ind starts/ends paused or not
if isempty(indSta) && isempty(indEnd) %One segment (e.g. if flat)
    indSta = 1;
    indEnd = length(dextF);
end
if indSta(1) > indEnd(1) %starts paused
    indSta = [1 indSta];
end
if indSta(end) > indEnd(end) %ends paused 
    indEnd = [indEnd length(dextF)];
end
%Get pause location, by averaging over the pause duration
pauseloc = arrayfun(@(x,y) mean(extF(x:y)), indSta, indEnd);
%Combine pauses if distance from last pause < 1bp
i = 2; %We're comparing the ith and i-1th pause
while i < length(pauseloc)
    %Check if the polymerase hasn't moved by more than 1bp
    if pauseloc(i) - pauseloc(i-1) < 1
        %combine pauses, do not increment i
        indSta(i) = [];
        indEnd(i-1) = [];
        pauseloc(i) = [];
    else
        i = i + 1;
    end
end
%Compute final pause list, plot
tf = zeros(1,length(extF));
for i = 1:length(indSta)
    tf(indSta(i):indEnd(i)) = 1;
end


%Calc pause distribution (seconds)
pslen = (indEnd - indSta + 1) / (samp(1)/samp(2));
pshei = arrayfun(@(x, y) mean(extF(x:y)), indSta, indEnd);

figure, hist(pslen, 100);

% extractedpauses = pslen( minpos < pshei & pshei < maxpos);
% pauseyouwant = max(pslen);

figure, plot(ext, 'Color', [.7 .7 .7]), hold on
surface([1:length(extF);1:length(extF)],[extF;extF],zeros(2,length(extF)),[tf;tf] ,'edgecol', 'interp')
plot(dextF / max(dextF) * max(extF))