function out = jbigau(x)

%Fit two gaussians to x, then HMM using means and pooled variance as HMM params

%Add step HMM finder
thispath = fileparts(mfilename('fullpath'));
addpath([thispath '\\..\\GUIDesign\\StepFind_HMM\\simpleHMM'])

[yb, xb] = histcounts(double(x), 100); %Make a weird number to try and have it not be a multiple of dV
xb = (xb(1:end-1) + xb(2:end) )/2; %Change to bin centers

%Fit to bigauss
bigauss = @(x0,x) normpdf(x, x0(1), x0(2))*x0(3) + normpdf(x, x0(4), x0(5))*x0(6);
%Fit only to edge parts
prclim = [40 60];
ki = xb > prctile(x,prclim(1)) & xb < prctile(x,prclim(2));
ki = ~ki;

%Make guesses
gumus= prctile(x, [25 75]);
gusd = std(x (x<prctile(x,50)) );
gun = length(x)/2 * median(diff(xb));
xg = double([gumus(1) gusd gun gumus(2) gusd gun]);
ft = lsqcurvefit(bigauss, xg, xb(ki), yb(ki), [], [], optimoptions('lsqcurvefit', 'Display', 'None'));
figure, plot(xb,yb), hold on, plot(xb, bigauss(ft,xb))
drawnow

%Extract mean, sig
mns = [ft(1) ft(4)];
sds = sqrt( ((ft(2)^2* ft(3) + ft(5)^2 * ft(6)))/(ft(3)+ft(6)) );

hmmfit = stateHMMV2(x, struct('ns', 2, 'mu', mns, 'sig', sds));

out = hmmfit.finish;

%Extract steps
tr = out.fit;
[in, ~] = tra2ind(tr);

dw = diff(in);
dwa = dw(1:2:end);
dwb = dw(2:2:end);

%Plot ccdf and fit
[af, ccdf, ax, ay] = fitexp(dwa, 0);
[bf, ~, bx, by] = fitexp(dwb, 0);
figure, plot(ax,ay), hold on, plot(ax, ccdf(af,ax))
plot(bx,by), plot(bx, ccdf(bf,bx))

%Split trace by state
xA = x(tr==1);
xB = x(tr==2);
fg = figure;
Calibrate(xA, struct('Fmin', 10, 'ra', 40, 'color', [0. 0. 1], 'lortype', 3, 'ax', subplot2(fg, [2 1], 1)));
Calibrate(xB, struct('Fmin', 10, 'ra', 40, 'color', [.2 .2 1], 'lortype', 3, 'ax', subplot2(fg, [2 1], 2)));



%What is dV on HiRes?
%I think it's 18-bit, so 20/2^18 or 4/2^18 depending on what range is set
%eps for single is way smaller (~1e-7 at 1) (23 bits)
%maybe 7.987e-5 by looking at differences? Close to 20/2^18 but that should be open in the range +-2 ?










