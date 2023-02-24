function out = minatmp(st, fns, kis)


len = length(fns);
dat = cell(1,len);

for i = 1:len
    dat{i} = st.(fns{i}).hi(kis{i});
end

%kdfsfind opts
opts.fpre = {0,1}; %pre filter. Dont filter for this data
opts.binsz = 0.2; %bin size, for kdf and hist
opts.kdfsd = 30; %kdf gaussian sd
opts.histdec = 5; %Step histogram decimation factor
opts.histfil = 10; %Filter width for step histogram
opts.kdfmpp = .75; %Multiplier to kdf MinPeakProminence
opts.histfitx = [0 100]; %X range to fit histfit to
opts.rmburst = 0; %Remove bursts in kdfdwellfind
opts.verbose = 0; %Plot

%Fit plot options
opts.dir = 1;
opts.toff = 5; %Time offset for plotting decompaction traces

%Extension time output
opts.extco = 6000; %bp, Extended = cross this number
opts.Fs = 1e3;

% anUnravel(dat, opts);
mint = 0.5; %minimum seconds for a dwell
minht = mint*1000* normpdf(0,0,opts.kdfsd);
out = cell(1,len);
for i = 1:len
    %Just use findpeaks with a minimum peak height (~= time spent)
    [tmpkdfy, tmpkdfx] = cellfun(@(x) kdf(x, opts.binsz, opts.kdfsd, [0 7000]), dat{i}, 'Un', 0);
    %findpeaks
    [~, locs] = cellfun(@(x,y) findpeaks(x, y, 'MinPeakHeight', minht), tmpkdfy, tmpkdfx, 'Un', 0);
    sszs = cellfun(@diff, locs, 'Un', 0);
    out{i} = [sszs{:}];
end

figure Name SszNew
hold on
for i = 1:len
    [y, x] = kdf(out{i}, opts.binsz, opts.kdfsd/2, [0 7000]);
    y = y / sum(y) / opts.binsz ; %Normalize
    plot(x,y)
end

legend( fns )
xlim([0 1000])








