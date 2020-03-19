function out = findEinstein(data, iny, inOpts)
%Tries to find a section of a trace that has the pattern in iny, for figure purposes
% Uses an algorithm that is like 'finding Einstein from noise' (bad), but is 'ok' if we corroborate with unbiased analysis
% Essentially this is what we would do by eye, anyway

%Default staircase
if nargin < 2
    iny = -2.5; %Repeating unit of pts to fit; e.g. a staircase of 2.5bp
end

%Uses @lsqcurvefit, which requires double
data = cellfun(@double, data, 'Un', 0);

%Options
opts.dy = 0.05; %y offset granularity to search over (will minimize with @lsq after)
opts.ptsmax = 1500; %Length of trace desired (in pts)
opts.rsdfun = @(x)x.^2; %Function to calculate the residual - try @abs or @(x) x.^2;
opts.maxlen = 3000; %Maximum trace segment length [divvy up otherwise], else HMM array size may be too large: need 4*length(iny)*opts.maxlen bytes
opts.minrng = 40; %Minimum range for a trace: a pause will score very well, but we don't want it
opts.hmmsig = max(abs(diff(iny)))/length(iny)/3; %Sigma for HMM, should be ~ 3 the difference between states? so jump is 3-sigma
opts.filwid = 10; %Filter half-width to use

%Handle options
if nargin > 2
    opts = handleOpts(opts, inOpts);
end

%Chop traces that are too long
data = cellfun(@(x)splitffb(x, opts.maxlen), data, 'Un', 0);
data = [data{:}];

len = length(data);
dataf = windowFilter(@mean, data, opts.filwid, 1);

%Generate the y offset vector
maxy = abs(iny(end));
dys = 0:opts.dy:maxy-eps(maxy)*100; %This is sloppy, but handles if opts.dy divides maxy as well as if it doesn't
hei = length(dys);

outtr = cell(1,len);
outft = cell(1,len);
outsc =  inf(1,len); %Set default score to be inf, so it's not selected
outin = ones(1,len); %Set default index to 1, so it doesn't error if used accidentally

%Harvest stuff from structs for parfor
rsdfun = opts.rsdfun;
npts = opts.ptsmax;
sig = opts.hmmsig;
minrng = opts.minrng;
%Set up progress bar [-----]
pipe = '|';
fprintf('[%s]', pipe(ones(1,len)));
gcp;
fprintf('\n[\n')
stT=tic;
%For every trace...
parfor i = 1:len
    tr0 = data{i};
    tr = dataf{i};
    %Only consider if > npts
    if length(tr) < npts
        continue
    end
    %Generate staircase heights that extends two steps before + after ; so we can just add dys to get the proper shifts
    nmin = floor( min(tr) / maxy) - 2;
    nmax =  ceil( max(tr) / maxy) + 2;
    muoff = nmin:nmax;
    %If we're moving backwards, reverse muoff to reflect that
    if iny(end) < 0 %#ok<PFBNS>, need whole iny anyway
        muoff = fliplr(muoff);
    end
    mu = bsxfun(@plus, iny(:), muoff * maxy);
    mu = mu(:)';
    ns = length(mu);
    %Set transition matrix as 
    a = diag(ones(1,ns)) + diag(ones(1,ns-1),+1)* ns / length(tr);
    a = bsxfun(@rdivide, a, sum(a,2));
    %Over each offset...
    tmptr = cell(1,hei);
    tmpft = cell(1,hei);
    tmpsc = inf(1,hei);
    tmpin = zeros(1,hei);
    for j = 1:hei
        %Fit a staircase [A one-way HMM thru iny]
        tmp = kdfdwfindHMM(tr, struct('sig', sig, 'mu', mu + dys(j), 'a', a), 0); %#ok<PFBNS>, need whole array
        %Find rsd at each point
        rsd = rsdfun(tr - tmp.fit); %#ok<PFBNS>
        %Find the best rsds for a region ptsmax long
        rsdsum = filter(ones(1,npts), 1, rsd); %This is a sum of the last N points
        rsdrng = abs(filter([-1 zeros(1,npts-2) 1], 1, tmp.fit)); %This is the 'range' of sections of N points
        %Void out those ranges where the trace is too flat
        rsdsum(rsdrng < minrng) = inf;
        %Find the minimum -- only take one section, limiting it to one nice section per FC
        [~, rsdmini] = min(rsdsum(npts:end));
        %If the minimum exists...
        if ~isempty(rsdmini)
            %Save trace section
            tmptr{j} = tr0(rsdmini:rsdmini+npts-1);
            tmpft{j} = tmp.fit(rsdmini:rsdmini+npts-1);
            %Find the best dy for this offset
            [optoff, optrsd] = lsqnonlin(@(x) (tr(rsdmini:rsdmini+npts-1)-tmpft{j}+x), 0, -maxy/2, maxy/2, optimoptions('lsqnonlin', 'Display','none'));
            %Update tmpft
            tmpft{j} = tmpft{j} + optoff;
            %Save score + position
            tmpsc(j) = optrsd;
            tmpin(j) = rsdmini;
        end
%         figure, plot(tr), hold on, plot(tmp.fit)
    end
    %Save only one trace per segment
    [rsdmin, rsdminj] = min(tmpsc);
    outtr{i} = tmptr{rsdminj};
    outft{i} = tmpft{rsdminj};
    outsc(i) = rsdmin;
    outin(:,i) = tmpin(rsdminj);
    fprintf('\b|\n')
end
fprintf('\b]\n')
fprintf('findEinstein finished on %s in %0.2fmin\n', inputname(1), toc(stT)/60);

%Assemble output into struct
out = struct('tr', outtr, 'ft', outft, 'sc', num2cell(outsc), 'in', num2cell(outin));
% out.tr = outtr;
% out.ft = outft;
% out.sc = outsc;
% out.in = outin;

% %Nullify scores of those with too short lengths - should probably do this in loop?
% rngs = cellfun(@range, outft);
% ki = rngs < opts.minrng;
% outsc(ki) = inf;

%Plot best 24 outscs, 3x8 matrix
matsz = [3 8];
[~, si] = sort(outsc(:));
fg = figure('Name', sprintf('FindEinstein: %s for pattern [%s]', inputname(1), ['[' sprintf('%0.2f,',iny) ']'] ));
for i = 1:min(length(si), prod(matsz));
    ax = subplot2(fg, matsz, i, 0);
    plot(ax, data{si(i)}( outin(si(i))+(0:npts-1) ) , 'Color', [.7 .7 .7])
    hold on
    plot(ax, outtr{si(i)}, 'Color', [.7 .7 .7] )
    plot(ax, windowFilter(@mean, outtr{si(i)}, opts.filwid, 1), 'Color', lines(1) )
    plot(ax, outft{si(i)}, 'Color', 'k');
    axis tight
    %Plotted with no space for axes limits, hide them (we dont need them)
    ax.XTickLabel = {};
    ax.YTickLabel = {};
end
    


