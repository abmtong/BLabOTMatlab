function out = plotMinaConds(dat, fns, inOpts)

opts.fil = 200; %Downsample by this much
opts.Fs = 1e3; %Fsamp
opts.minlen = 10; %Trace length, s
opts.nplot = inf; %How many traces to plot (max)
opts.medbands = 3; %Plot median trace as data bands (=1 SD, =2 MAD, =3 IQR)

if nargin > 2
    opts = handleOpts(opts, inOpts);
end

fgL = figure('Name', 'Low force condensation', 'Color', [1 1 1]);
fgH = figure('Name', 'Hi force unwinding', 'Color', [1 1 1]);

pad = [0.1 .05 .1 .05]; %Padding on left/right/bottom/top

n = length(fns);

axswid = (1-pad(1)-pad(2))/n;
axshei = 1-pad(3)-pad(4);

for i = n:-1:1
    %Make axes
    axsL(i) = axes(fgL, 'Position', [pad(1) + (i-1) * axswid, pad(3), axswid, axshei]);
    axsH(i) = axes(fgH, 'Position', [pad(1) + (i-1) * axswid, pad(3), axswid, axshei]);
    hold(axsL(i), 'on')
    hold(axsH(i), 'on')
    tmp = dat.(fns{i});
    %Grab traces
    datlo = tmp.lo;
    dathi = tmp.hi;
    %Filter (downsample)
    datlo = cellfun(@(x) windowFilter(@mean, x, [], opts.fil), datlo, 'Un', 0);
    dathi = cellfun(@(x) windowFilter(@mean, x, [], opts.fil), dathi, 'Un', 0);
    %Filter (reject)
    datlo = datlo( cellfun(@length, datlo) > opts.minlen*opts.Fs/opts.fil );
    dathi = dathi( cellfun(@length, dathi) > opts.minlen*opts.Fs/opts.fil );
    %If nplot < ntraces, pick a random assortment to plot
    kilo = randperm(length(datlo), min(length(datlo), opts.nplot));
    kihi = randperm(length(dathi), min(length(dathi), opts.nplot));
    %Plot: vary color evenly in hue-space, with some color-jitter to separate traces
    cellfun(@(x) plot( axsL(i), (1:length(x))/opts.Fs*opts.fil, x, 'Color', hsv2rgb( mod((i-1)/n + (rand-0.5)/5, 1) , 1, .7) ), datlo(kilo))
    cellfun(@(x) plot( axsH(i), (1:length(x))/opts.Fs*opts.fil, x, 'Color', hsv2rgb( mod((i-1)/n + (rand-0.5)/5, 1) , 1, .7) ), dathi(kihi))
    
    %Plot median trace
    %Extend each trace by its final value...
    lenlo = max(cellfun(@length, datlo));
    datlox = cellfun(@(x) [x x(end) * ones(1, lenlo-length(x))]', datlo, 'Un', 0);
    medlo = median([datlox{:}], 2)';
    
    lenhi = max(cellfun(@length, dathi));
    dathix = cellfun(@(x) [x x(end) * ones(1, lenhi-length(x))]', dathi, 'Un', 0);
    medhi = median([dathix{:}], 2)';
    
    %If plotting a data band:
    if opts.medbands
        switch opts.medbands
            case 1 %+-SD
                medlob = std([datlox{:}], [], 2)';
                medhib = std([dathix{:}], [], 2)';
                medloblo = medlo - medlob;
                medlobhi = medlo + medlob;
                medhiblo = medhi - medhib;
                medhibhi = medhi + medhib;
            case 2 %+-MAD (median absolute dev)
                medlob = mad([datlox{:}]', 1);
                medhib = mad([dathix{:}]', 1);
                medloblo = medlo - medlob;
                medlobhi = medlo + medlob;
                medhiblo = medhi - medhib;
                medhibhi = medhi + medhib;
            case 3 %IQR, so 25th and 75th percentile (or +- pctdif percentile)
                pctdif = 25; %Set to 25 for quartiles
                medloblo = prctile([datlox{:}], 50-pctdif, 2)';
                medlobhi = prctile([datlox{:}], 50+pctdif, 2)';
                medhiblo = prctile([dathix{:}], 50-pctdif, 2)';
                medhibhi = prctile([dathix{:}], 50+pctdif, 2)';
        end
        xxl = (1:length(medlo))/opts.Fs*opts.fil;
        xxl = [xxl fliplr(xxl)]; %#ok<AGROW>
        xxh = (1:length(medhi))/opts.Fs*opts.fil;
        xxh = [xxh fliplr(xxh)]; %#ok<AGROW>
        
        %Plot options for the data band (how transparent)
        facealpha = 0.15;
        %And plot
        patch( axsL(i), xxl, [medloblo fliplr(medlobhi)], zeros(1, 2* length(medlo)), zeros(1, 2* length(medlo)), 'FaceColor', zeros(1,3), 'FaceAlpha', facealpha )
        patch( axsH(i), xxh, [medhiblo fliplr(medhibhi)], zeros(1, 2* length(medhi)), zeros(1, 2* length(medhi)), 'FaceColor', zeros(1,3), 'FaceAlpha', facealpha )
    end
    
    plot( axsL(i), (1:length(medlo))/opts.Fs*opts.fil, medlo, 'k', 'LineWidth', 2 )
    plot( axsH(i), (1:length(medhi))/opts.Fs*opts.fil, medhi, 'k', 'LineWidth', 2 )
    
    
    %Plot lines at 'starting' and 'ending' points, x=0 and x=6256
    plot(axsL(i), [1e3 -1 -1 1e3], [6256 6256 0 0], 'Color', [.4 .4 .4], 'LineWidth', 2)
    plot(axsH(i), [1e3 -1 -1 1e3], [6256 6256 0 0], 'Color', [.4 .4 .4], 'LineWidth', 2)
    
    %Count N traces and N cycles
    nmsL = tmp.loN;
    nmsH = tmp.hiN;
    %These are names '%s_L%02d.mat', so just strip the last 8 chars. Fails if %02d overflows, but w/e
    nmsL = cellfun(@(x) x(1:end-8), nmsL, 'Un', 0);
    nmsH = cellfun(@(x) x(1:end-8), nmsH, 'Un', 0);
    
    nn{i} = [length(nmsL), length(nmsH), length(unique(nmsL)), length(unique(nmsH))]; %N lo, N hi, N traces lo, N traces hi
    
    %Title
    titstr = regexprep(regexprep(fns{i}, '(?<=[a-z])M(?=[A-Z])', ' -'), '(?<=[a-z])P(?=[A-Z])', ' +'); %Convert 'MASF1' to ' -ASF1' etc.
    title(axsL(i), titstr)
    title(axsH(i), titstr)
    
    if i ~= 1 %Remove YTicks for the non-leftmost graph, as the plots will overlap each other
        axsH(i).YTickLabel = [];
        axsL(i).YTickLabel = [];
    end
    
end


linkaxes(axsL, 'xy')
linkaxes(axsH, 'xy')
axsL(1).XLim = [0 95]; %Try to set an xlim such that there is no overlapping (i.e., there is no xtick on the right edge)
axsL(1).YLim = [-500 6500];

axsH(1).XLim = [0 95];
axsH(1).YLim = [-500 6500];

out = reshape([nn{:}], 4, [])'; %TBD, right now just outputs [N ext, N cond, N tot ext, N tot cond], last two should be equal