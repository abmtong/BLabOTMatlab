function out = RPp3bV2(inst, inOpts)
%Calc rip transition path histogram

%V2: add rip force histogram, deconvolution

opts.fil = 5; %Filter (smooth, dont downsample)
opts.filtype = 2; %Filter type, =1 for mean, =2 for median, =3 for savitsky-golay with order 1

opts.wid = [200 200]; %Pts to take on each side of the rip
opts.tpmeth = 1; %Method for cropping TPs, 0 = just window, 1 = also do Woodhouse-like TPs (cross x1 to cross x2)

%Options if tpmeth == 1
opts.tpwid = [0.1 0.9]; %Crossing lines for determining TPs
opts.tppad = 100; %Pts to pad on each side after finding the TP
opts.tppadmult = 0.5; %Pts to pad on each side, as a multiple of the tp length
opts.tpfil = 10; %Filtering for TPs for detection, different from opts.fil (filter more to get a more noise-independent TP detection

opts.tpzero = 0; %Zero the F side of the TP, i.e. subtract by median of pre-rip

% opts.pwlcc = 0.38*106; %Protein size (nm)
% opts.pwlcfudge = 1; %Protein size offset, nm

opts.refold = 0; %Calc refolding vs. unfolding
                 % Right now, doesn't work for TP calc-ing

opts.usetfpbe = [1 1]; %Uses tfpbe1 and tfpbe2, if they exist (see RPpickbyeyeGUI). Make [0 0] to disable

%Plotting options
opts.verbose = 1; %Plot
opts.Fs = 25e3; %Fsamp, just for conversion to time
opts.conbinsz = 0.5; %Contour histogram bin size
opts.ngauss = 4; %Number of gaussians to fit contour histogram to
opts.gauguess = []; %Guess for gaussian means. Defaults to evenly-spaced, if empty

opts.convdat = [3, 0]; %Model for the bead movement, as convolution with exp(-( 0:convdat(2) ) / convdat(1) ); decent starting value is Fc/Fsamp
                        % Set convdat(2) == 0 to turn off. Try to keep convdat(2) / convdat(1) > 5 or so
% opts.convdat = [3, 10]; %Model for the bead movement, as convolution with exp(-( 0:(2) ) / (1) ); decent starting value is Fc/Fsamp

opts.fripmeth = 1; %Rip force calculation method
opts.fripbin = 0.5; %Rip force bin size
opts.fripco = 0; %Rip force percentile cutoff

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


len = length(inst);
tpcrp = cell(1,len); %Transition path crop
tpcrpr = cell(1,len); %Transition path crop raw (unfiltered)
frip = zeros(1,len); %Force of rip
for i = 1:len
    %Get protein contour
    tmp = inst(i);
    yy = double( tmp.conpro );
    
    %Scale if factor exists
    if isfield(tmp, 'pclscale')
        yy = yy * tmp.pclscale;
        opts.pwlcc = tmp.xwlcft(7) * tmp.pclscale;
    else
        opts.pwlcc = tmp.xwlcft(7);
    end
    
    %Sloppy, but hotwire refolding index as rip index and invert
    if opts.refold
        tmp.ripind = tmp.refind;
        %And flip to keep F>U direction
        yy = opts.pwlcc - yy;
    end
    if isempty(tmp.ripind)
        continue
    end

    %Crop just the TP, with some padding so filtering/deconv is ok
    pad = max( opts.fil, opts.convdat(2)*2 );
    irng = tmp.ripind - opts.wid(1) - pad : tmp.ripind + opts.wid(2) + pad;
    %If crop range is out of bounds, just skip. Shouldn't happen for 'good' files
    if irng(1) < 1 || irng(end) > length(yy)
        %Skip this one
        tpcrp{i} = inf;
        tpcrpr{i} = inf;
        continue
    end
    %And apply crop
    yy = yy(irng);
    
    %Deconvolve protein contour, if asked
    if opts.convdat(2) > 0
        %Model as exp decay
        convfil = exp(-(0:opts.convdat(2))/opts.convdat(1));
        %Normalize
        convfil = convfil / sum(convfil);
        yy = [ deconv(yy, convfil) zeros(1,length(convfil)-1)]; %Deconv removes length(convfil)-1 points, so re-add them
    end
    
    %Filter
    if opts.fil > 0
        switch opts.filtype
            case 1 %Mean
                yf = windowFilter(@mean, yy, opts.fil, 1);
            case 2 %Median
                yf = windowFilter(@median, yy, opts.fil, 1);
            case 3 %Sgolay, rank 1
                yf = sgolayfilt(yy, 0, 1+2*opts.fil);
            otherwise %Undefined, fallback to mean
                warning('Filter type %d not defined, using mean', opts.filtype)
                yf = windowFilter(@mean, yy, opts.fil, 1);                
        end
    else
        yf = yy;
    end
    
    %Un-pad
    yy = yy(pad+1:end-pad);
    yf = yf(pad+1:end-pad);
    
    %Zero, if asked
    if opts.tpzero
        if opts.refold
            yy = yy - median(yy(round(end/2):end));
            yf = yf - median(yf(round(end/2):end));
        else
            yy = yy - median(yy(1:round(end/2)));
            yf = yf - median(yf(1:round(end/2)));
        end
    end
    
    %Crop to just the transition path, if asked
    if opts.tpmeth == 1
        %Bounds are 0 and opts.pwlcc, two lines x1 and x2 are at tpwid(1) and tpwid(2) times that distance (e.g. 0.2, 0.8 = at 20% and 80% the way there)
        %Find the last time the trace crosses x1 to the first time it crosses x2
        % Lets assume the crossing is one-way, so we don't have to check for going backwards
        %Filter specially for this method
        yftp = windowFilter(@mean, yy, opts.tpfil, 1);
        %Invert if opts.refold -- already done above.
%         if opts.refold
%             yftp = opts.pwlcc - yftp;
%         end
        ind1 = find( yftp < opts.tpwid(1) * opts.pwlcc, 1, 'last');
        ind2 = find( yftp > opts.tpwid(2) * opts.pwlcc, 1, 'first');
        %And NaN out things outside of ind1:ind2, with some padding
        pad2 = round( (ind2 - ind1) * opts.tppadmult );
        ind1 = max( 1, ind1 - opts.tppad - pad2 );
        ind2 = min( length(yy), ind2 + opts.tppad + pad2);
        ki = false(1,length(yy));
        ki(ind1:ind2) = true;
        yy(~ki) = nan;
        yf(~ki) = nan;
    end
    
    %Rip force: Take the highest force, after filtering
    ff = windowFilter(@mean, tmp.frc(irng), opts.fil, 1);
    ff = ff(1+pad:end-pad);
    frip(i) = max(ff);
    
    %Save
    tpcrp{i} = yf;
    tpcrpr{i} = yy;
end
%Remove empty entries if they were skipped, or wild outliers or NaN
ki1 = ~cellfun(@(x)isempty(x) || max(abs(x))>opts.pwlcc*100 || all(isnan(x)), tpcrp);

% %Remove entries with wild outliers
% ki2 = ~ (cellfun(@(x) max(abs(x)), tpcrpr) > opts.pwlcc * 100);

% %Remove all-NaN entries
% ki5 = ~(cellfun(@(x) isempty(x) || all(isnan(x)), tpcrp));

%Remove entries manually picked with RPpickbyeyeGUI
ki3 = true(size(tpcrp));
if isfield(inst, 'tfpbe1') && opts.usetfpbe(1)
    ki3 = ki3 & [inst.tfpbe1];
end
if isfield(inst, 'tfpbe2') && opts.usetfpbe(2)
    ki3 = ki3 & [inst.tfpbe2];
end
if ~all(ki3)
    fprintf('Rejected %d/%d traces by picking\n', sum(~ki3), length(ki3))
end

%Remove entries based on rip force
fco = prctile(frip, opts.fripco);
ki4 = frip >= fco;

%Join and apply data removal
% ki = ki1 & ki2 & ki3 & ki4 & ki5;
ki = ki1 & ki3 & ki4;
tpcrp = tpcrp(ki);
tpcrpr = tpcrpr(ki);
frip = frip(ki);
inst = inst(ki);

%If these were from multiple files, separate
if isfield(inst, 'file')
    nams = {inst.file};
    [uu, ~, ic] = unique(nams);
    nfil = max(ic);
    for i = nfil:-1:1
        out(i).name = uu{i};
        out(i).tps = tpcrp( ic == i );
        out(i).tpsr = tpcrpr( ic == i );
        out(i).frip = frip( ic == i );
    end
else
    out.name = '';
    out.tps = tpcrp;
    out.tpsr = tpcrpr;
    out.frip = frip;
end

if opts.verbose
    %Plot TPs
    figure('Name', sprintf('RossPull p3b. Name: %s, fil: %d, filtype, %d, wid: [%d %d], tpmeth: %d, usetfpbe:[%d %d]', inputname(1), opts.fil, opts.filtype, opts.wid(1), opts.wid(2), opts.tpmeth, opts.usetfpbe(1), opts.usetfpbe(2) ), 'Color', [1 1 1])
    xx = (-opts.wid(1) : opts.wid(2) ) / opts.Fs * 1e3;
    subplot(3, 1, 1), hold on
    %Plot trace snippets
    cellfun(@(x)plot(xx,x), tpcrp)
    %Plot line at bottom and top
    plot( [xx(1) xx(end)] , [0 0], 'r', 'LineWidth', 1)
    plot( [xx(1) xx(end)] , opts.pwlcc * [1 1], 'g', 'LineWidth', 1)
    %plot 'median' one
    medtr = median( reshape( [tpcrp{:}], length(tpcrp{1}), [] ), 2, 'omitnan');
    plot(xx, medtr, 'k', 'LineWidth', 2)
    xlim(opts.wid.*[-1 1]/ opts.Fs * 1e3 )
    yl = [ min(medtr, [], 'omitnan') max(medtr, [], 'omitnan') ] + range(medtr) * 0.5 .* [-1 1];
    ylim(yl)
    title('Transition Paths')
    xlabel('Time (ms)')
    ylabel('Protein Contour (nm)')
    
    %Plot contour histogram
    ax = subplot(3,1,2); hold on
    [~, x, ~, y] = nhistc( [tpcrp{:}], opts.conbinsz );
    %Normalize: total N per bin -> N per molecule per nm
    y = y / opts.conbinsz / length(tpcrp) / opts.Fs * 1e3;
    %Plot and fit to N gaussians
    ngaufit_cf(x,y, opts.ngauss, ax, opts.gauguess);
    xlim(yl)
    title('Residence Time Histogram')
    xlabel('Protein Contour (nm)')
    ylabel('Time (ms/nm)')
    axis tight
    
    %Plot rip force histogram
    subplot(3,1,3), hold on
    [p, x] = nhistc(frip, opts.fripbin);
    bar(x,p)
    title('Rip Force')
    xlabel('Rip Force (pN)')
    ylabel('Probability')
end