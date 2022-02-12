function out = anUnravel(trs, inOpts)

%Do kdfsfind on all

%kdfsfind opts
opts.fpre = {10,1}; %pre filter
opts.binsz = 0.2; %bin size, for kdf and hist
opts.kdfsd = 5; %kdf gaussian sd
opts.histdec = 5; %Step histogram decimation factor
opts.histfil = 10; %Filter width for step histogram
opts.kdfmpp = .5; %Multiplier to kdf MinPeakProminence
opts.histfitx = [0 100]; %X range to fit histfit to
opts.rmburst = 0; %Remove bursts in kdfdwellfind
opts.verbose = 0; %Plot

%Extension time output
opts.extco = 6000; %bp, Extended = cross this number
opts.Fs = 1e3;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

[pkloc, ssz] = cellfun(@(x) kdfsfindV2(x, opts), trs, 'Un', 0);

[hp, hx, hsd, hn] = cellfun(@(x) nhistc(x, opts.histdec), ssz, 'Un', 0);

figure('Name', 'anUnravel', 'Color', [1 1 1])
hold on
cellfun(@(x,y,z) plot(x,y,'Color', z), hx, hp, arrayfun(@(x) hsv2rgb(x, 1, .7), (0:length(hx)-1)/length(hx), 'Un', 0)  )

%Find extension times, fit 1exp?
len = length(trs);
tcr = cell(1,len);
for i = 1:len
    tmp = cellfun(@(x) find(x > opts.extco, 1, 'first'), trs{i}, 'Un', 0);
    tmp = [tmp{:}];
    tmp(tmp==1) = []; %Remove traces that start already extended
    tcr{i} = tmp;
end
%Plot ccdf
plccdf = @(x) plot( sort(x)/opts.Fs, (length(x):-1:1)/length(x) );
figure, hold on, cellfun(plccdf, tcr)
set(gca, 'YScale', 'log')

out.tcr = tcr;



