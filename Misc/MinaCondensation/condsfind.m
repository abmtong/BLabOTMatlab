function out = condsfind(inst, inOpts)

%Takes input struct, does kdfsfind on them
%Split trace, do vdist on the edges to maybe see condensin movement?

%kdfsfind opts
opts.fpre = {10,1}; %pre filter
opts.binsz = 0.1; %bin size, for kdf and hist
opts.kdfsd = 1; %kdf gaussian sd
opts.histdec = 2; %Step histogram decimation factor
opts.histfil = 5; %Filter width for step histogram
opts.kdfmpp = .5; %Multiplier to kdf MinPeakProminence
opts.histfitx = [0 15]; %X range to fit histfit to
opts.rmburst = 0; %Remove bursts in kdfdwellfind
opts.verbose = 1; %Plot

%vdist opts

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%For each structure...
fns = fieldnames(inst);
len = length(fns);
outraw = cell(1,len);
outraw2 = cell(1,len);
for i = 1:len
    dat = inst.(fns{i});
    [pklocs, ~, histfits] = kdfsfindV2(dat, setfield(opts, 'verbose', 0));
%     tmp = cellfun(@(x) kdfsfindV2(x, opts), dat, 'Un', 0);
    trs = cellfun(@trkdfsfind, dat, pklocs, 'Un', 0);
    if opts.verbose == 2 %Plot all fits
        figure('Name', sprintf('Fitting for %s', fns{i}))
        hold on
        colli = colorcircle(length(pklocs)+1, 0.6); %Light, trace color
        coldk = colorcircle(length(pklocs)+1, 0.3); %Dark, fit color
        cellfun(@(x,y) plot(windowFilter(@mean, x, opts.fpre{:}), 'Color', y, 'LineWidth', 0.5), dat, colli)
        cellfun(@(x,y) plot(x(:,1), x(:,2), 'Color', y, 'LineWidth', 1.0), trs, coldk)
    end
    
    outraw{i} = pklocs;
    outraw2{i} = histfits;
end

%Plot step size histograms
figure('Name', 'Step Size Histograms')
hold on
colli = colorcircle(len+1, 0.6);
for i = 1:len
    plot(outraw2{i}.x, smooth(outraw2{i}.y, opts.histfil), 'Color', colli{i});
end


%Turn output into struct
% out = struct(fns, out); e.g.

%Verbose: To plot stepfinding or not [how to show without dwellfinding -- draw lines ? then that's just one line per]
% Maybe get an 'envelope' for each trace, and only draw the lines within that envelope. Would like for it to be one line, though

%Assemble to some unified output 