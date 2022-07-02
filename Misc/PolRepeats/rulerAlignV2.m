function [out, outraw] = rulerAlignV2(tra, inOpts)
%Time to just write it in matlab...
%Works okay!? Method is distinct from Antony's but seems to work

%{
Editing to be more Antony-like
RTH: Instead of binning points, bin 'segments' : draw a line between i and i+1-th pt, [still one per pt.]
  They did this to ensure no 0 bins, if log is taken. Gaussian smoothing does this for me, though.
%Probably not essential for my case

Similarity Score
I use var(), reference uses third moment of logprb, they used prob chk
  (third moment, using the hist as a prob dist.)
%}

 %check effect of binsm, filwid, etc.

%Input data unit is bp
%out is data scaled and offset to start at the begining of the repeat section
%outraw is extra info (scale/offset params, histogram data)

%Convert to double
if isa(tra, 'single')
    tra = double(tra);
end

%Filtering options
opts.filwid = 20; %Smoothing filter half-width (pts)
opts.binsm = 1; %Residence time histogram filter half-width (bp)
opts.rptsmsd = 1; %Smooth the histogram
opts.persmsd = 0.1; %Smooth the period scores with a gaussian filter of this std (bp)
opts.offsmsd = 1; %Smooth the offset scores with a gaussian filter of this std (bp)
opts.Fs = 3125; %Fsamp, just for plotting X-axis

%Options: Repeat pause characteristics
opts.start = tra(1); %Start position, bp
opts.pauloc = [83 108 141 168 236]; %Known pause location, shown for the His molecular ruler
opts.paustr = [.15 .25 .15 .25 .25]; %Known pause strength (taken from doi:10.1038/s41467-018-05344-9), 'combined conditions'
opts.per = 239; %Repeat length, bp
opts.persch = [.9 1.1]; %Search range, proportion of period
opts.perschd = .05; %Granularity of search, bp; also doubles as the bin size [was .025nm in Antony code, which is .07bp]
opts.permeth = 2; %Method to generate average RTH, see code
opts.scrmeth = 1; %Method to score a RTH, see code
opts.nrep = 8; %Number of repeats

%To improve:
%Hm seems to be sensitive to filtering (i.e. binsm) - fixed, binsm now is in bp, not pts (now only pts field is filwid)
% Make sure filtering is centered (or filter the xdata as well?) - guessing some shifting may be occurring [not too bad for offset, but bad for per]

%Options: Alignment analysis
opts.trim = 0; %Trim edges of the estimated repeat range by this amount (e.g. 0.01 to trim 1% from top and bottom)

opts.verbose = 1;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%If input is cell, loop
if iscell(tra)
    thisfcn = str2func(mfilename);
    if nargin > 1
        [out, outraw] = cellfun(@(x) thisfcn(x, inOpts), tra, 'Un', 0);
    else
        [out, outraw] = cellfun(@(x) thisfcn(x), tra, 'Un', 0);
    end
    ki = ~cellfun(@isempty, out);
    nums = 1:length(tra);
    
    nums = nums(ki);
    out = out(ki);
    outraw = [outraw{ki}];
    
    %Plot some stats
    offs = [outraw.off];
    scls = [outraw.scl];
    offscrs = [outraw.offscr];
    sclscrs = [outraw.sclscr];
    figure('Name', sprintf('RulerAlign Scatter %s', inputname(1)))
    scatter(offs, scls, [], offscrs/range(offscrs) + sclscrs/range(sclscrs), 'filled')
    for i = 1:length(offs)
        text(offs(i), scls(i), sprintf('%d', nums(i)));
    end
    colormap winter
    colorbar
    
    %Plot aligned traces
    figure('Name', sprintf('RulerAlign Traces %s', inputname(1)))
    hold on
    cellfun(@(x)plot((1:floor(length(x)/(2*opts.filwid+1)))/opts.Fs*(2*opts.filwid+1), windowFilter(@mean, x, [], 2*opts.filwid+1) ), out)
    xl = xlim;
    arrayfun(@(x) plot(xl, x * [1 1]), bsxfun(@plus, opts.pauloc, (0:opts.nrep-1)'*opts.per))
    cellfun(@(x, y) text( length(x)/opts.Fs, x(end), sprintf('%d', y) ), out, num2cell(nums))
    %Plot aligned histogram
    [sumy, sumx] = sumNucHist(out, setfield(setfield(opts, 'verbose', 1), 'disp', [])); %#ok<SFLD>
    %Plot sum histogram
    inds = arrayfun(@(x) find(sumx >= x, 1, 'first'), (0:opts.nrep)*opts.per);
    yy = median( reshape( sumy(inds(1):inds(end)-1), [], opts.nrep ), 2 )';
    xx = sumx(inds(1):inds(2)-1);
    figure, plot(xx,yy);
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

%If none of the trace is in the search region, return
if all(~ki)
    out = [];
    outraw=[];
    return
end

hp = windowFilter(@mean, hp, ceil(opts.binsm/opts.perschd), 1);

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
    %Generate period histogram (across repeats)
    switch opts.permeth
        case 1 %Take mean of the residence times
            rpt = mean( reshape(php(1:opts.nrep*persn(i)), persn(i), opts.nrep),2, 'omitnan')';
        case 2 %Use median instead of mean - should better handle random pausing?
            rpt = median( reshape(php(1:opts.nrep*persn(i)), persn(i), opts.nrep),2, 'omitnan')';
    end
    rpts{i} = gausmooth(rpt, opts.per/persn(i), opts.rptsmsd, 1);

    %Try out various scoring methods...
    switch opts.scrmeth
        case 1 %Score by taking its mean quadratic error [as a proxy for 'spikiness']
            scr(i) = var(rpt, 1);
        case 2 %Herbert 2006, skewness of log-rth [third moment]
            %First smooth to remove 0s
            tmp = gausmooth(rpt, opts.per/persn(i), opts.persmsd, 0);
            %Take log of probability
            tmp = log(tmp);
            %Normalize
            tmp = tmp / sum(tmp);
            %Skewness = E[ (X-mu/std)^3 ]
            x = linspace(0, opts.per, persn(i)+1);
            x = x(1:end-1);
            mu = sum(x.*tmp);
            sd = sqrt(sum( (x - mu).^2 .* tmp )) ;
            scr(i) = sum( (x - mu).^3 .* tmp ) / sd^3;
            scr(i) = skewness(tmp);
        case 3 %Something closer to Antony's code: Probability of each repeat given the other repeats
            
            
            
    end
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
elseif isempty(fp)
    fp = [1 1 0];
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
%Gaussian smooth this : if per is off by a bit, peaks are flat; smoothing helps find the center
rptpau = gausmooth(rptpau, opts.per/length(rptpau), opts.offsmsd, 1);

%Judge 'goodness' by findpeaks
fp = sort(findpeaks(rptpau), 'descend');
if length(fp) == 1
    offscr = 1;
elseif isempty(fp)
    warning('No peaks found in rulerAlign')
    out = [];
    outraw = [];
    return
else
    %Judge score by relative height of second peak
    offscr = 1-(fp(2) - fp(end)) / range(fp);
end
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
