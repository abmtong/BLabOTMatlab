function out = vdist_filling(inx, inOpts)
%Calculates velocity distribution of a trace that goes to high filling by filling amt.
%Filter traces, bin them by location, plot their histograms, take fit peak

if ~iscell(inx) 
    inx = {inx};
end

%Define default sgolay options
opts.sgp = {1 301}; %"Savitsky Golay Params"
opts.vbinsz = 2; %Velocity BIN SiZe
opts.Fs = 2500; %Frequency of Sampling

%Define filling options
opts.cbinsz = 1000; %bin every x bp

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Filter with sgolay
[vels, cons] = cellfun(@(x)sgolaydiff(x, opts.sgp),inx,'Uni',0);
vels = -[vels{:}]*opts.Fs; %invert so packaging = positive, convert to /sec from /pt
cons = [cons{:}];

%define bin edges
cbins = (floor(min(cons)/opts.cbinsz):ceil(max(cons)/opts.cbinsz)) * opts.cbinsz;
%and bin centers
cbinx = cbins(1:end-1) + opts.cbinsz/2;

%sort by contour
[vn, ~, cind] = histcounts(cons, cbins);
%bin vel by contour
vbin = arrayfun(@(x) vels(cind == x), 1:max(cind), 'uni', 0);

%do essentially what @vdist does to every trace
% I do this all in cellfun, probably easier to read as for loop, but vOv
%Make vel hist bounds
minvf = floor(min(vels) / opts.vbinsz) * opts.vbinsz;
maxvf =  ceil(max(vels) / opts.vbinsz) * opts.vbinsz;
vxbins = double(minvf:opts.vbinsz:maxvf);
vxbinx = vxbins(1:end-1) + opts.vbinsz/2;
%bin vel by vel
vybin = cellfun(@(x)histcounts(x, vxbins), vbin, 'un', 0);
%normalize
vybin = cellfun(@(x) x/sum(x)/opts.vbinsz, vybin, 'un', 0);

%setup fitting
%pdf to two gaussians centered at 0 and [positive]
bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) ;
xg = [0 20 .2 100 30 .8];
lb = [0 0 0   0 0 0];
ub = [0 inf 1 300 inf 1];
%lsq options
lsqopts = optimoptions('lsqcurvefit');
lsqopts.Display = 'none';
%fit using @lsqcurvefit
fits = cellfun(@(x)lsqcurvefit(bigauss, xg, vxbinx, x, lb, ub, lsqopts), vybin, 'un', 0);
%calculate fit curve
fitc = cellfun(@(x)bigauss(x, vxbinx), fits, 'un', 0);

%extract fits as a matrix, for easier access to columns
fitmat = reshape([fits{:}], 6, [])';

%and plot

%xform position to percent packaged
%construct is 21kb, so
%amt packaged = 21k - position
%pct pkgd = amt / 19k

cbinpct = (21e3 -cbinx )/19e3*100;

%graph 1: velocity-position graph
%calculate error on velocity = SD gauss / sqrt n
vs = fitmat(:,4)';
vsd = fitmat(:,5)';
vse = vsd./ sqrt(vn);
figure Name Vel-Pos
errorbar(cbinpct, vs, vse)
xlabel PctPacked
ylabel Velocity(bp/s)

%graph 2: pause-position graph
pau = fitmat(:,3)';
pauE = 1./sqrt(vn.*pau); %error on a count = 1/sqrt(n), n = pau * N
figure Name Pause-Pos
errorbar(cbinpct, pau, pauE)
xlabel PctPacked
ylabel PausePct

%checking graph 1: all hists
figure Name CheckHists
hold on
cols = getcol(1:length(cbinpct));
colsm = reshape( [cols{:}], 3, [])';
cellfun(@(y,c)plot(vxbinx, y,'Color', c), vybin, cols)
cellfun(@(y,c)plot(vxbinx, y,'Color', c, 'LineWidth', 1), fitc, cols)
colorbar
set(gca, 'clim',[cbinpct(end) cbinpct(1)])
colormap(flipud(colsm))

%checking graph 2: N
figure Name N
bar(cbinpct, vn)

out = {vs vsd vn cbinx cbinpct pau fitmat};



