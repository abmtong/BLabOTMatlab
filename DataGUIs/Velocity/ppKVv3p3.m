function out = ppKVv3p3(inst)
%Calculates mean pause length by fitting tloc section of dwell dist to a gamma [regular dwell] + tail (paused state)

Fs=2500;
t0 = 0.2; %s , for linear fitting
tmaxfit = .2; %s , for gamma fitting
binsz = .02; %s, should be integer / 500 [= 2500 / KV dec fact]
smfact = 1;
method = 2;

%Force range to analyze [only use low force]
frange = [5 15];

%Extract translocation data
dat = inst.tl;
datfrc = [dat.frc];

%Only work with low force
dat = dat(datfrc > frange(1) & datfrc < frange(2));

%Get dwell distribution
inds = {dat.ind};
dws = cellfun(@diff, inds, 'Un', 0);
dws = cellfun(@(x) x(2:end-1)/Fs, dws, 'Un', 0);
dws = [dws{:}];
[yp, xp, ~, ~] = nhistc(dws, binsz);
yp = smooth(yp, smfact)';

%Fit gamma
fitki = xp <= tmaxfit;
lb = [5 0];
ub = [5 inf];
[gfit, ~, gamfun] = fitgamma(xp(fitki), yp(fitki), lb, ub);
fitp = gamfun(gfit, xp);

%Now do this integral somehow to get the mean pause time.
switch method
    case 1 %Fit exponentials [lines in log space] to tails. Not great, as the gauss tail isn't quite -exp
        %Crop to tails. Is there a better way to do this besides just setting a number?
        ki = xp > t0;
        xc = xp(ki);
        yc = yp(ki);
        yfc = fitp(ki);
        %Fit exponentials [lines in log space]
        lyc = log(yc);
        lyfc = log(yfc);
        
        %log(data) may go to -inf, cut off data after that point
        indend = find(isinf(lyc),1,'first')-1;
        if isempty(indend)
            indend = length(xc);
        end
        
        ftdat = polyfit(xc(1:indend), lyc(1:indend), 1);
        ftfit = polyfit(xc(1:indend), lyfc(1:indend), 1);
        
        %Calculate intersection, = db / dm
        xint = ftdat-ftfit;
        xint = -xint(2)/xint(1);
        
        %Integrate from this intersection to infinity to get probability of being paused
        %A line with (m,b) in log space is exp(mx+b) in linear space
        %Integrate [solved by hand] to get area = chance of being paused:
        ppaused = exp(polyval(ftdat, xint))/ftdat(1) - exp(polyval(ftfit, xint))/ftfit(1);
        ppaused = -ppaused;
        npaused = length(dws) * ppaused;
        evtprkb = npaused / sum(cellfun(@(x) x(1)-x(end), {dat.mea}))*1000;
        %Get average value to get mean dwell time
        %This is x * the above integrand
        intxex = @(mb, x) exp(mb(1) * x) * (1 - x * mb(1)) / mb(1)^2 * exp(mb(2));
        pavg = (intxex(ftdat, xint) - intxex(ftfit, xint)) / ppaused;
    case 2 %Discrete integral of data minus gamma fit. Preferred method.
        lyc2 = log(yp);
        lyfc2 = log(fitp);
        x2 = find(isinf(lyc2),1,'first')-1;
        if isempty(x2)
            x2 = length(xp);
        end
        %Find crossing pt
        x1 = find(lyc2(1:x2) < lyfc2(1:x2), 1, 'last') + 1;
        %Remove zeroes
        ki = yp > 0;
        ki(1:x1-1) = false;
        pcr = yp(ki) - fitp(ki);
        xcr = xp(ki);
        %Integrate
        ppaused = binsz * sum( pcr );
        pavg = binsz * sum( pcr .* xcr ) /  ppaused ;
        psd = sqrt(binsz * sum( pcr .* (xcr-pavg).^2 ) /  ppaused);
        npaused = length(dws) * ppaused;
        evtprkb = npaused / sum(cellfun(@(x) x(1)-x(end), {dat.mea}))*1000;
        %Also calculate median
        cdf = cumsum(binsz * ( yp(x1:x2) - fitp(x1:x2) ));
        medi = find(cdf < ppaused/2 , 1, 'last');
        pmed = xp(medi+x1-1);
    case 3 %Hybrid, use fit line for data [...but we dont expect it to be single exp] minus the fit gamma, integrate discretely
        %Crop to tail
        ki = xp > t0;
        xc = xp(ki);
        yc = yp(ki);
        
        %Fit exponential [lines in log space]
        lyc = log(yc);
        %log(data) may go to -inf, cut off data after that point
        indend = find(isinf(lyc),1,'first')-1;
        if isempty(indend)
            indend = length(xc);
        end
        %And fit
        ftdat = polyfit(xc(1:indend), lyc(1:indend), 1);
        ypl = exp(polyval(ftdat, xp));
        
        %Do the rest of method 2 but with line
        lyc2 = log(ypl);
        lyfc2 = log(fitp);
        x2 = find(isinf(lyc2),1,'first')-1;
        if isempty(x2)
            x2 = length(xp);
        end
        %Find crossing pt
        x1 = find(lyc2(1:x2) < lyfc2(1:x2), 1, 'last') + 1;
        %Remove zeroes
        ki = ypl > 0;
        ki(1:x1-1) = false;
        pcr = ypl(ki) - fitp(ki);
        xcr = xp(ki);
        %Integrate
        ppaused = binsz * sum( pcr );
        pavg = binsz * sum( pcr .* xcr ) /  ppaused ;
        psd = sqrt(binsz * sum( pcr .* (xcr-pavg).^2 ) /  ppaused);
        npaused = length(dws) * ppaused;
        evtprkb = npaused / sum(cellfun(@(x) x(1)-x(end), {dat.mea}))*1000;
        %Also calculate median
        cdf = cumsum(binsz * pcr);
        medi = find(cdf < ppaused/2 , 1, 'last');
        pmed = xp(medi+x1-1);
    otherwise
end
%And plot
switch method
    case 1
        out = [npaused, pavg, psd, psd/sqrt(npaused), ppaused*100, evtprkb, gfit];
        figure('Name', sprintf('PPKVp3 %s, N = %0.1f, MeanPause = %0.4f+-%0.4f(%.04f), PctPaused = %0.2f, Evt/kb = %0.3f, Gamma (%0.2f, %0.4f)\n', ...
            inputname(1), out))
        plot(xp, yp), hold on, plot(xp,fitp)
        plot(xp, exp(polyval(ftdat, xp)))
        plot(xp, exp(polyval(ftfit, xp)))
    case 2
        out = [npaused, pavg, psd, psd/sqrt(npaused), pmed, ppaused*100, evtprkb, gfit];
        figure('Name', sprintf('PPKVp3 %s, N = %0.1f, MeanPause = %0.4f+-%0.4f(%.04f), Median = %0.4f, PctPaused = %0.2f, Evt/kb = %0.3f, Gamma (%0.2f, %0.4f)\n', ...
            inputname(1), out))
        plot(xp, yp), hold on, plot(xp,fitp)
    case 3
        out = [npaused, pavg, psd, psd/sqrt(npaused), pmed, ppaused*100, evtprkb, gfit];
        figure('Name', sprintf('PPKVp3 %s, N = %0.1f, MeanPause = %0.4f+-%0.4f(%.04f), Median = %0.4f, PctPaused = %0.2f, Evt/kb = %0.3f, Gamma (%0.2f, %0.4f)\n', ...
            inputname(1), out))
        plot(xp, yp), hold on, plot(xp,fitp)
        plot(xp, exp(polyval(ftdat, xp)))
    otherwise
end
set(gca, 'YScale', 'log')

