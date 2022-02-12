function [out, outraw] = rulerAlign(tra, inOpts)
%Time to just write it in matlab...
%Works okay!? Method is distinct from Antony's but seems to work

%Input data unit is bp
%out is data scaled and offset to start at the begining of the repeat section
%outraw is extra info (scale/offset params, histogram data)

%Filtering options
opts.filwid = 20; %Smoothing filter half-width
opts.binsm = 20; %Residence time histogram filter half-width
opts.persmsd = 0.5; %Smooth the period scores with a gaussian filter of this std (bp)
opts.offsmsd = 1; %Smooth the offset scores with a gaussian filter of this std (bp)

%Options: Repeat pause characteristics
opts.start = tra(1); %Start position, bp
opts.pauloc = [83 108 141 168 236]; %Known pause location
opts.paustr = [.15 .25 .15 .25 .25]; %Known pause strength (taken from doi:10.1038/s41467-018-05344-9)
opts.per = 239; %Repeat length, bp
opts.persch = [.9 1.1]; %Search range, proportion of period
opts.perschd = .05; %Granularity of search, bp; also doubles as the bin size [was .025nm in Antony code, which is .07bp]
opts.nrep = 8; %Number of repeats

%Options: Alignment analysis
opts.trim = 0; %Trim edges of the estimated repeat range by this amount (e.g. 0.01 to trim 1% from top and bottom)

opts.verbose = 1;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%If input is cell, loop
if iscell(tra)
    if nargin > 1
        [out, outraw] = cellfun(@(x) rulerAlign(x, inOpts), tra, 'Un', 0);
    else
        [out, outraw] = cellfun(@(x) rulerAlign(x), tra, 'Un', 0);
    end
    outraw = [outraw{:}];
    
    %Plot some stats
    offs = [outraw.off];
    scls = [outraw.scl];
    offscrs = [outraw.offscr];
    sclscrs = [outraw.sclscr];
    figure
    scatter(offs, scls, [], offscrs/range(offscrs) + sclscrs/range(sclscrs), 'filled')
    colormap winter
    colorbar
    
    %Plot aligned traces
    figure, hold on, cellfun(@(x)plot( windowFilter(@mean, x, opts.filwid, 1) ), out)
    xl = xlim;
    arrayfun(@(x) plot(xl, x * [1 1]), bsxfun(@plus, opts.pauloc, (0:opts.nrep-1)'*opts.per))
    cellfun(@(x, y) text( length(x), x(end), sprintf('%d', y) ), out, num2cell(1:length(out)))
    return
end

%Filter the data
traF = windowFilter(@mean, tra, opts.filwid, 1);

%Bin
binsz = opts.perschd; %Might want to use a different binsz, so keep separate
[hp, hx] = nhistc(traF, binsz);

%Make search range. Is this necessary?
rng = opts.start + [0 opts.nrep * opts.per] .* (1 + [opts.trim, -opts.trim]);

%Crop hx to the search region
ki = hx > rng(1) & hx < rng(2);
hx = hx(ki); %Hm this isn't used, but we probably want to use hx to reference where we are?
hp = hp(ki);

hp = windowFilter(@mean, hp, opts.binsm, 1);

%Generate periods to search over
persn = (opts.persch * opts.per)/opts.perschd; %Generate range
persn = floor(persn(1)):ceil(persn(2)); %Periods in number of binsizes
pers = persn * opts.perschd; %Periods in bp

%Pad py with mean(py) to be at least nrep*max_period pts long
% If using mean, pad with mean because then it [shouldnt] interfere with peaks
% php = [hp mean(hp) * ones(1, max( persn(end)*opts.nrep - length(hp),0))];
% If using median, pad with nan and use nanflag 'omitnan' when taking median
php = [hp nan(1, max( persn(end)*opts.nrep - length(hp),0))];

len = length(pers);
scr = zeros(1,len);
rpts = cell(1,len);

%Score each period
for i = 1:len
    %Generate period histogram (sum together repeats)
    %Take mean of the residence times
    rpt = mean( reshape(php(1:opts.nrep*persn(i)), persn(i), opts.nrep),2, 'omitnan')';
    %Use median instead of mean - should better handle random pausing?
%     rpt = median( reshape(php(1:opts.nrep*persn(i)), persn(i), opts.nrep),2, 'omitnan')';
    rpts{i} = rpt;
    
    %Try out various scoring methods...
    %Score by taking its mean quadratic error
    scr(i) = var(rpt, 1);
end
%Smooth period score
scr = gausmooth(scr, opts.perschd, opts.persmsd, 0);

%Choose best score
[~, maxi] = max(scr); %Is there a better way to get this? Maybe interp spline?
per = pers(maxi); %Period
rpt = rpts{maxi}; %Repeat histogram
scl = opts.per/per; %Scaling factor

%Judge 'goodness' by findpeaks
fp = sort(findpeaks(scr), 'descend');
if length(fp) == 1
    fp = [fp min(fp)];
end
%Judge score by relative height of second peak
sclscr = 1-(fp(2) - fp(end)) / range(fp);

%Find offset by finding best overlap with peak locations
%Get locations of pauses in this frame of reference
paulocscl = opts.pauloc / scl;
pauind = round(paulocscl / binsz); %Get pause locations in terms of indicies

%Sum along every possible pause location
rptpau = zeros(1, persn(maxi));
for i = 1:length(pauind);
    rptpau = rptpau + circshift(rpt, [0, -pauind(i)]) * opts.paustr(i);
end
%Gaussian smooth this : if per is off by a bit, peaks are flat
rptpau = gausmooth(rptpau, opts.perschd, opts.offsmsd, 1);

%Judge 'goodness' by findpeaks
fp = sort(findpeaks(rptpau), 'descend');
%Judge score by relative height of second peak
offscr = 1-(fp(2) - fp(end)) / range(fp);

%% Not certain this isn't off by +-1 perschd ... but who cares?

%Choose maximum
[~, maxi] = max(rptpau);
%Convert to offset
maxi = maxi - 1;
off = hx(1) + maxi*binsz;
%Handle sign: shift by wid to be closest to start
off = off + round( (opts.start - off) / opts.per*scl ) * opts.per*scl;

%Output: Scaled trace
out = (tra  - off)* scl;

outraw.off = off;
outraw.scl = scl;
%Aligned repeat histogram
outraw.rephist = circshift(rpt, [0 -maxi]);
outraw.rephistx = (0:length(rptpau)-1)*binsz*scl;
%Histograms from which the scale/offset are found. May want to check that these have one obvious peak.
outraw.sclraw = scr; %Period score graph
outraw.sclrawx = pers;
outraw.sclscr = sclscr;
outraw.ohist = rptpau; %Offset score graph
outraw.ohistx = outraw.rephistx;
outraw.offscr = offscr;

if opts.verbose
    rulerAlignChk(outraw, opts.pauloc)
end
