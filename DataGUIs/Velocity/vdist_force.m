function out = vdist_force(trc, frc, inOpts)

opts.fbinsz = 2; %pN
opts.sem = 0; %Use SEM over SD
opts.verbose = 1;

%vdist opts
%Define default options
opts.sgp = {1 301}; %"Savitzky Golay Params"
opts.vbinsz = 2; %Velocity BIN SiZe
opts.Fs = 2500; %Frequency of Sampling
% Options for plotting, if requested
opts.velmult = 1; %Velocity multiplier, set to -1 if negative velocity is forwards (for proper fitting)
opts.vfitlim = [-inf inf]; %Velocity to fit over
opts.fitmethod = 1;
opts.xlim = [-inf inf];
%Plot traces
opts.verboseplot = 0;
opts.verboseplotsd = 2;

if ~iscell(trc)
    trc = {trc};
    frc = {frc};
end

if nargin > 2
    opts = handleOpts(opts, inOpts);
end


%Going to be similar to vdist_filling but binning across force instead of position

%Filter with sgolay
[vels, ~] = cellfun(@(x)sgolaydiff(x, opts.sgp), trc,'Uni',0);
vels = -[vels{:}]*opts.Fs; %invert so packaging = positive, convert to /sec from /pt
[~, frcf] = cellfun(@(x)sgolaydiff(x, opts.sgp), frc,'Uni',0);
frcf = [frcf{:}];

%Define force bin edges
fbins = (floor(min(frcf)/opts.fbinsz):ceil(max(frcf)/opts.fbinsz)) * opts.fbinsz;
%and bin centers
fbinx = fbins(1:end-1) + opts.fbinsz/2;

%Sort by frc
[fn, ~, cind] = histcounts(frcf, fbins);
%bin vel by frc
vbin = arrayfun(@(x) vels(cind == x), 1:max(cind), 'uni', 0);

%do essentially what @vdist does to every trace but then bin by progress
% I do this all in cellfun, probably easier to read as for loop, but vOv
%Make vel hist bounds
minvf = floor(min(vels) / opts.vbinsz) * opts.vbinsz;
maxvf =  ceil(max(vels) / opts.vbinsz) * opts.vbinsz;
vxbins = double(minvf:opts.vbinsz:maxvf);
vxbinx = vxbins(1:end-1) + opts.vbinsz/2;
%Calculate histogram
vybin = cellfun(@(x)histcounts(x, vxbins), vbin, 'un', 0);
%normalize
vybin = cellfun(@(x) x/sum(x)/opts.vbinsz, vybin, 'un', 0);

%setup fitting
%pdf to two gaussians centered at 0 and [positive]
bigauss = @(x0, y) normpdf(y, x0(1), x0(2))*x0(3) + normpdf(y, x0(4), x0(5))*x0(6) ;
xg = [0 20 .2 100 30 .8];
lb = [0 0 0   0 0 0];
ub = [0 inf 1 inf inf 1];
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

%graph 1: velocity-position graph
%calculate error on velocity = SD gauss / sqrt n
vs = fitmat(:,4)';
vsd = fitmat(:,5)';
if opts.sem
    vse = vsd./ sqrt(fn./opts.sgp{2});
else
    vse = vsd;
end
if opts.verbose
    figure('Name', sprintf('Vel-Force %s', inputname(1)))
    errorbar(fbinx, vs, vse)
    xlabel('Force')
    ylabel('Velocity (bp/s)')
end

%graph 2: pause-force graph
pau = fitmat(:,3)';
if opts.sem
    pauE = 1./sqrt(fn./opts.sgp{2}.*pau) ./ (fn./opts.sgp{2}); %SEM on a count = sqrt(n)/n, n = pau * N; but this is a prb, so E = E / N
else
    pauE = 1./sqrt(pau*opts.sgp{2}); %SD on a count is sqrt(n)
end
if opts.verbose
    figure ('Name', sprintf('Pause-Force %s', inputname(1)))
    errorbar(fbinx, 100*pau, 100*pauE)
    xlabel('Force')
    ylabel('Time paused (%)')
end

%checking graph 1: all hists
if opts.verbose
    figure ('Name', sprintf('CheckHists %s', inputname(1)))
    hold on
    cols = getcol(1:length(fbinx));
    colsm = reshape([cols{:}], 3, [])';
    cellfun(@(y,c)plot(vxbinx, y,'Color', c), vybin, cols)
    cellfun(@(y,c)plot(vxbinx, y,'Color', c, 'LineWidth', 1), fitc, cols)
    colorbar
    set(gca, 'clim',sort( fbinx([1 end]) ))
    colormap(flipud(colsm))
end

%checking graph 2: N
if opts.verbose
    figure('Name', sprintf('N %s', inputname(1)))
    bar(fbinx, fn)
    xlabel('Force')
    ylabel('N')
end
%Vel, sd, n, fbin, pct paused, fit [0mean 0sd 0pct , vmean vsd vpct]
out = [vs' vsd' fn' fbinx' pau' fitmat];



