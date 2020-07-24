function fitgamma_old(dws, varargin)
%Uses same input as nhistc
%THERE are two fitgammas, in /Plotting and /Helpers - should merge

%Calculate histogram
[yy, xx] = nhistc(dws, varargin{:});
%X cutoff
prc = 5; %Percentile cutoff
xmn = prctile(dws, prc);
xmx = prctile(dws, 100-prc);
%Fit to gamma dist (k, th)
gamm   = @(x0,x) x0(3) * x.^(x0(1)-1) .* exp(-x/x0(2)) / gamma(x0(1)) /x0(2)^x0(1);
lb = [1 0 0];
ub = [inf inf 1];
gu = [4 .1/4 1]; %Guess k=4, mean = 0.1 = k*th
ft = lsqcurvefit(gamm, gu, xx(xx<=xmx & xx >= xmn), yy(xx<=xmx& xx >= xmn), lb, ub, optimoptions('lsqcurvefit', 'Display', 'off'));
mn = mean(dws(dws<=xmx & dws >= xmn));
sd = std(dws(dws<=xmx & dws >= xmn));
%And plot
figure('Name', sprintf('fitgamma %s: k %0.2f, mean %0.3f +- %0.3f (SEM)', inputname(1), ft(1), ft(1)*ft(2), ft(1)*ft(2)/sqrt(ft(3)*length(dws))))
plot(xx,yy), hold on, plot(xx, gamm(ft, xx)), line( xmx*[1 1], ylim), line( xmn*[1 1], ylim)
text( (ft(1)-1) * ft(2), max(yy), sprintf('Gamma with k = %0.2f, th = %0.5f, amp %0.3f', ft))
text( (ft(1)-1) * ft(2), max(yy)*.5,sprintf('Naive guess mean: %0.3f, sd: %0.3f, nmin: %0.2f\n', mn, sd, mn^2/sd^2))
xlim([0 2*xmx])