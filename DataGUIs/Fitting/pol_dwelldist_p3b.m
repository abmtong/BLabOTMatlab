function [out, kn] = pol_dwelldist_p3b(rawdat, p1tra, p2exps, inOpts)
%Plots traces, coloring steps by dwelltime
%dat is the raw data, p1tra is the fit staircase, exps is the fit exponentials
%  p1tra is the third output of p1
%  p2exps is list of the fit exponentials [a1, k2, a2, k2, ...], taken from the output of p2

%Fsamp (Hz)
opts.Fs = 1000;
opts.fil = 10; %Filter by this many pts
%Extra analyses to do
opts.bstrap = 1; %Also calculate boostrapped probability?
opts.blockp = 0; %Also do Block's 'pauses per 100bp' thing ? [pause = non-major a_i] - Only for cell batch

%Cell batch-mode options
opts.dt = 2; %delay by each trace by dt in cell-mode.
opts.toff = 0;
opts.ax = [];
opts.figtitle = '';

if nargin > 3
    opts = handleOpts(opts, inOpts);
end

%If input is cell or struct, iterate

if isstruct(rawdat)
    %For each fieldname...
    %Do for dat(fn{i}), tra(fn{i}), exps(fn{i}.fit)
    %May make a lot of graphs...
    fns = fieldnames(rawdat);
    nn = length(fns);
    for i = 1:nn
        opts.figtitle = fns{i};
        [out.(fns{i}), kn.(fns{i})] = pol_dwelldist_p3b(rawdat.(fns{i}), p1tra.(fns{i}), p2exps.(fns{i}).fit, opts);
    end

    return
end
if iscell(rawdat)
    figure Name PolDwellDistP3b
    opts.ax = gca;
    
    hold on
    nn = length(rawdat);
    out = zeros(nn+1,6);
    kn = cell(1,nn);
    for i = 1:nn
        opts.toff = (i-1)*opts.dt;
    	[out(i,:), kn{i}] = pol_dwelldist_p3b(rawdat{i},p1tra{i},p2exps, opts);
    end
    title(opts.figtitle)
    xlabel('Time (s)')
    ylabel('Position (bp)')
    
    %Do random test on all
    if opts.bstrap
        %For each dwell, calculate most likely source exponential
        kns = [kn{:}];
        [op, oraw] = randomCheck_bstrap(kns);
        out(nn+1,:) = [op, length(kns), oraw.nruns, mean(oraw.nboot), std(oraw.nboot), length(oraw.nboot) ];
    end
    
    if opts.blockp
        dwbin = 100; %dwbin should be > offset variance
        %For each dwbin bp, calculate pause chance
        [~, mes] = cellfun(@tra2ind, p1tra, 'Un', 0);
        bins = (floor(min([mes{:}]/dwbin)):ceil(max([mes{:}]/dwbin)))*dwbin;
        %Group means and kn's
        allme = [mes{:}];
        allkn = [kn{:}];
        %Find the highest a_i and call this the 'pause-free' and take anything slower as a pause
        as = p2exps(1:2:end);
        [~, kpfv] = max(as);
        %Store number of pauses, dwells in each region
        npau = zeros(1, length(bins)-1);
        ndw  = zeros(1, length(bins)-1);
        for i = 1:length(bins)-1
            kncrop = allkn( allme >= bins(i) & allme < bins(i+1) );
            ndw(i) = length(kncrop);
            npau(i) = sum(kncrop > kpfv); %Slower than kpfv (= higher k_i) = pause
        end
        cimult = 1.96; %SD to 95%CI for a count [i.e. Z-score for 0.05]
        
        figure('Name', 'PDDp3b Block - Pause Probability')
        %Plot pause prob. as bars, with errorbars
        bar(bins(1:end-1), npau./ndw, 'FaceColor', [.5 .5 1])
        hold on
        errorbar(bins(1:end-1), npau./ndw, npau.^0.5./ndw * cimult, 'LineStyle', 'none');
        title(opts.figtitle)
        xlabel('Position (nm)')
        ylabel('Pause Chance')
    end
    
    return
end

%Fit tra if not passed
if isempty(p1tra)
    if isfield(opts, 'fvopts')
        [~, trs] = fitVitterbi_batch(rawdat, setfield(opts.fvopts, 'verbose', 0)); %#ok<SFLD>
    else
        [~, trs] = fitVitterbi_batch(rawdat, struct('verbose', 0));
    end
    p1tra = trs{1};
end
[in, me] = tra2ind(p1tra);
dws = diff(in) / opts.Fs;

%Get CLim
mindw = min(dws);
maxdw = max(dws);
crange = log([mindw maxdw]);

%Handle clim issues: if length(dws) == 1, 
crange(2) = crange(2) + eps(crange(2));

%For cell operation, always expand clim
if ~isempty(opts.ax)
    fg = opts.ax.Parent;
    if any(isa( fg.Children , 'matlab.graphics.illustration.ColorBar' ))
        crange = [ min( crange(1), opts.ax.CLim(1) ) , max( crange(2), opts.ax.CLim(2) ) ];
    end
end

%Make colormap
as = p2exps(1:2:end);
ks = p2exps(2:2:end);
hues = 60*(0:length(as)-1); %Use hues 60-degrees apart: R Y G Cy B Pu

%Set say 100pts of hue
cv = logspace( log10(mindw) , log10(maxdw) , 100);

%Get the expected exponential at this pt.
%= sum( hue(i) * ai * ki * exp(-ki t) )
hnum = sum( bsxfun( @times, hues .* as .* ks, bsxfun( @(x,y) exp(x*y), -ks, cv(:))), 2);
hdem = sum( bsxfun( @times, as .* ks, bsxfun( @(x,y) exp(x*y), -ks, cv(:))), 2);
hs = hnum ./ hdem;
cmap = hsv2rgb([mod(hs,360)/360 ones(length(hs), 2)]);

%Make staircase coordinates

%X-coords are in(1 2 2 3 3 4 4 5 5 ... end)
xs = [in(1:end-1) ; in(2:end)];
xs = xs(:)';
%Y-coords are me(1 1 2 2 3 3 4 4 ... end end)
ys = [me; me];
ys = ys(:)';
%C-coords are log(dw*Fs)

cs = log( [dws; dws] );
cs = cs(:)';

%Plot raw data, grey
if isempty(opts.ax)
    figure
    opts.ax = gca;
end
plot(opts.ax, (1:length(rawdat))/opts.Fs + opts.toff, windowFilter(@mean, rawdat, ceil(opts.fil/2), 1), 'Color', [.7 .7 .7])
hold on
surface(opts.ax, [xs; xs]/opts.Fs + opts.toff, [ys; ys], zeros(2, length(xs)), [cs; cs], 'EdgeColor', 'interp', 'LineWidth', 1)
ax = gca;
ax.CLim = crange;
colormap(cmap)
colorbar


if opts.bstrap || nargout > 1
    %For each dwell, calculate most likely source exponential
    [~, kn] = arrayfun(@(x) max( as .* ks .* exp(- ks * x ) ) , dws); %pdf = ai * ki * exp(-ki t)
end

%Calculate boostrapped clustering probability
out = nan(1,5); %[p nsteps nruns mean(bstrap) sd(bstrap) nboot]
if opts.bstrap
    [op, oraw] = randomCheck_bstrap(kn);
    out = [op, length(kn), oraw.nruns, mean(oraw.nboot), std(oraw.nboot), length(oraw.nboot) ]; %p, nruns, bstrap mean, bstrap sd, nboot
    text(opts.ax, double(xs(end))/opts.Fs + opts.toff, double(ys(end)), sprintf('%0.3f', op) );
end
