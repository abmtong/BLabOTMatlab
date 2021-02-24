function [out, outraw] = rulerAlign(tra, inOpts)
%Time to just write it in matlab...
%Works okay!? Method is distinct from Antony's but seems to work

%Input data unit is bp
%out is data scaled and offset to start at the begining of the repeat section
%outraw is extra info (scale/offset params, histogram data)

dbg = 0;

%General options
% opts.Fs = 3125; %Default Fs for Lumicks files. Just there for speeds, not really necessary
opts.filwid = 20; %Smoothing filter width
opts.binsm = 20; %Smooth the histogram, since npts is low [alternatively, replace histogram binning with kdf]

%Options: Repeat pause characteristics
opts.start = tra(1); %Start position, bp
opts.pau = struct('a', {83 .15}, 'b', {108 .25}, 'c', {141 .15}, 'd', {168 0.25}, 'h', {236 0.25}); %Pause names and their location, strength (taken from doi:10.1038/s41467-018-05344-9)
opts.per = 239; %Repeat length, bp
opts.persch = [.9 1.1]; %Search range, proportion of period
opts.perschd = .05; %Granularity of search, bp; also doubles as the bin size [was .025nm in Antony code, which is .07bp]
opts.nrep = 8; %Number of repeats

%Options: Alignment analysis
opts.trim = 0; %Trim edges of the estimated repeat range by this amount

%If input is cell, 
if iscell(tra)
    if nargin > 1
        [out, outraw] = cellfun(@(x) rulerAlign(x, inOpts), tra, 'Un', 0);
    else
        [out, outraw] = cellfun(@(x) rulerAlign(x), tra, 'Un', 0);
    end
    outraw = [outraw{:}];
    return
end

if nargin > 1
    opts = handleOpts(opts, inOpts);
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
    %Generate cyclic histogram (sum together repeats)
    %Take mean of the residence times
%     rpt = mean( reshape(php(1:opts.nrep*persn(i)), persn(i), opts.nrep),2)';
    %Use median instead of mean - should better handle random pausing?
    rpt = median( reshape(php(1:opts.nrep*persn(i)), persn(i), opts.nrep),2, 'omitnan')';
    rpts{i} = rpt;
    
    %Try out various scoring methods...
    %Score by taking its mean quadratic error
    scr(i) = var(rpt, 1);
    
end

%Choose best score
[~, maxi] = max(scr); %Is there a better way to get this? Maybe interp spline?
per = pers(maxi); %Period
rpt = rpts{maxi}; %Repeat histogram
scl = opts.per/per; %Scaling factor

%Find offset by finding best overlap with peak locations
%Get locations of pauses in this frame of reference
pauloc = struct2cell(opts.pau(1));
paustr = struct2cell(opts.pau(2));
paustr = [paustr{:}];
paulocscl = [pauloc{:}] / scl;
pauind = round(paulocscl / binsz); %Get pause locations in terms of indicies

%Sum along every possible pause location
rptpau = zeros(1, persn(maxi));
for i = 1:length(pauind);
    rptpau = rptpau + circshift(rpt, [0, -pauind(i)]) * paustr(i);
%     rptpau = rptpau + circshift(rpt, [0, -pauind(i)+1]);
%     rptpau = rptpau + circshift(rpt, [0, -pauind(i)-1]);
end
% rptpau = rptpau / length(pauind);
[~, maxi] = max(rptpau);

if dbg
    figure, plot((0:length(rptpau)-1)*binsz*scl,circshift(rpt,[0,-maxi])), hold on, plot((0:length(rptpau)-1)*binsz*scl,rptpau)
    yl=ylim;
    cellfun(@(x) plot( x * [ 1 1] , yl), pauloc)
end

%Convert maxi to offset
maxi = maxi - 1;
o = [maxi length(rptpau)-maxi];
[~, ji] = min(abs(o));
o = o(ji);
off = opts.start + o*binsz;

%Output: Scaled trace
out = tra  * scl - off;

outraw.off = off;
outraw.scl = scl;
%Aligned repeat histogram [not offset fixed]
outraw.rephist = circshift(rpt, [0 -maxi]);
%Histograms from which the scale/offset are found. May want to check that these have one obvious peak.
outraw.sclraw = scr; %Period score
outraw.ohist = rptpau; %Histogram for offset

