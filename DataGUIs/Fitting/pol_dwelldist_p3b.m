function [out, kn] = pol_dwelldist_p3b(rawdat, p1tra, p2exps, inOpts)
%Plots traces, coloring steps by dwelltime
%dat is the raw data, p1tra is the fit staircase, exps is the fit exponentials
%  p1tra is the third output of p1
%  p2exps is list of the fit exponentials [a1, k2, a2, k2, ...], taken from the output of p2


opts.Fs = 1000;

opts.bstrap = 0; %Also calculate boostrapped probability?

%Cell batch-mode options
opts.dt = 2; %delay by each trace by dt in cell-mode.
opts.toff = 0;
opts.ax = [];

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
        [out.(fns{i}), kn.(fns{i})] = pol_dwelldist_p3b(rawdat.(fns{i}), p1tra.(fns{i}), p2exps.(fns{i}).fit, opts);
        title(gca, fns{i})
    end

    return
end
if iscell(rawdat)
    figure Name PolDwellDistP3b
    opts.ax = gca;
    nn = length(rawdat);
    out = zeros(nn+1,5);
    kn = cell(1,nn);
    for i = 1:nn
        opts.toff = (i-1)*opts.dt;
    	[out(i,:), kn{i}] = pol_dwelldist_p3b(rawdat{i},p1tra{i},p2exps, opts);
    end
    
    %Do random test on all
    if opts.bstrap
        %For each dwell, calculate most likely source exponential
        kns = [kn{:}];
        [op, oraw] = randomCheck_bstrap(kns);
        out(nn+1,:) = [op, oraw.nruns, mean(oraw.nboot), std(oraw.nboot), length(oraw.nboot) ];
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
plot(opts.ax, (1:length(rawdat))/opts.Fs + opts.toff, rawdat, 'Color', [.7 .7 .7])
hold on
surface(opts.ax, [xs; xs]/opts.Fs + opts.toff, [ys; ys], zeros(2, length(xs)), [cs; cs], 'EdgeColor', 'interp', 'LineWidth', 1)
ax = gca;
ax.CLim = crange;
colormap(cmap)
colorbar


%Calculate boostrapped clustering probability
out = [];
if opts.bstrap
    %For each dwell, calculate most likely source exponential
    [~, kn] = arrayfun(@(x) max( as .* ks .* exp(- ks * x ) ) , dws); %pdf = ai * ki * exp(-ki t)
    
    [op, oraw] = randomCheck_bstrap(kn);
    out = [op, oraw.nruns, mean(oraw.nboot), std(oraw.nboot), length(oraw.nboot) ]; %p, nruns, bstrap mean, bstrap sd, nboot
    text(opts.ax, double(xs(end))/opts.Fs + opts.toff, double(ys(end)), sprintf('%0.3f', op) );
end

