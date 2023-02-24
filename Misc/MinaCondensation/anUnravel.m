function [out, ssz] = anUnravel(trs, inOpts)

%Do kdfsfind on all

%kdfsfind opts
opts.fpre = {0,1}; %pre filter. Dont filter for this data
opts.binsz = 0.2; %bin size, for kdf and hist
opts.kdfsd = 20; %kdf gaussian sd; data is ~20
opts.histdec = 15; %Step histogram decimation factor
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

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

[pkloc, ssz, ~ , ~, fts] = cellfun(@(x) kdfsfindV2(x, opts), trs, 'Un', 0);

[hp, hx, hsd, hn] = cellfun(@(x) nhistc(x, opts.histdec), ssz, 'Un', 0);
% hp = cellfun(@(x) windowFilter(@mean, x, opts.histfil, 1), hp, 'Un', 0);
% hx = cellfun(@(x) windowFilter(@mean, x, opts.histfil, 1), hx, 'Un', 0);

cols = arrayfun(@(x) squeeze( hsv2rgb(x, 1, .7) ), (0:length(trs)-1)/length(trs), 'Un', 0);
cols = reshape([cols{:}], 3, [])';

figure('Name', 'anUnravel', 'Color', [1 1 1])
hold on
set(gca, 'ColorOrder', cols)
cellfun(@(x,y,z) plot(x,y,'Color', z), hx, hp, arrayfun(@(x) hsv2rgb(x, 1, .7), (0:length(hx)-1)/length(hx), 'Un', 0)  )

%Plot traces + fits
% fts = cell(1,length(trs));
for i = 1:length(trs)
    figure('Name', sprintf('anUnravel Fits %d', i))
    hold on
    ax = gca;
    tmp = trs{i};
%     fts{i} = cellfun(@(x,y)fitVitterbiV3(x, struct('mu', y, 'sig', mean(diff(y)), 'ssz', min(diff(y)))), trs{i}, pkloc{i}, 'Un', 0);
    for j = 1:length(tmp);
        yy = tmp{j};
        xx = (1:length(yy))/opts.Fs + (j-1) * opts.toff;
        tt = fts{i}{j};
        
        %Plot source data, grey
        ci = ax.ColorOrderIndex;
        plot(xx,yy, 'Color', [.7 .7 .7]);
        
        %Plot trace fit, colored
        ax.ColorOrderIndex = ci;
        plot(xx,tt)
        
        %Label n_steps with text
        text(xx(1),tt(1), sprintf('%d', length( tra2ind(tt))-2))
    end
end

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
figure, hold on, set(gca, 'ColorOrder', cols), cellfun(plccdf, tcr)
set(gca, 'YScale', 'log')

xl = xlim;
yl = ylim;

%Fit to 1exp (curvefit)
expcc = @(x0,x) exp(-x0*x);
expfts = cell(1,len);
for i = 1:len
    tmp = sort(tcr{i});
    expfts{i} = lsqcurvefit( expcc, 10, tmp/opts.Fs, (length(tmp):-1:1)/length(tmp) );
    xpl = linspace(0, max(tmp)/opts.Fs, 11);
    plot( xpl, expcc( expfts{i}, xpl ), ':')
end
%Retain original lims
xlim(xl)
ylim(yl)

out.tcr = tcr;
out.tfit = expfts;



