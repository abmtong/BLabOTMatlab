function out = RPp4b(inst, inOpts)
%Calc refolding transition path histogram

%Eh probably still too high noise...

opts.fil = 20; %Filter (smooth, dont downsample)
% opts.meth = 1; %Window method
opts.wid = [200 200]; %Pts to take on each side of the rip

opts.pwlcc = 0.38*127; %Protein size (nm)
% opts.pwlcfudge = 1; %Protein size offset, nm

opts.verbose = 1; %Debug plots

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


len = length(inst);
tpcrp = cell(1,len);
for i = 1:len
    %Get protein contour
    tmp = inst(i);
    yy = tmp.conpro( tmp.retind:end );
    ff = tmp.frc( tmp.retind:end );
    
    %Filter
%     yf = forcefilter(yy, ff, opts.fil);
    yf = windowFilter(@median, yy, opts.fil, 1);
    %Crop
    irng = tmp.refind - tmp.retind + 1 - opts.wid (1) : tmp.refind - tmp.retind + 1 + opts.wid(2);
    if any(irng < 1 | irng > length(yf))
        %Skip this one
        continue
    end
    yc = yf(irng);
    
    %Save
    tpcrp{i} = yc;
end
%Remove empty entries if they were skipped
ki = ~cellfun(@isempty, tpcrp);
tpcrp = tpcrp(ki);
inst = inst(ki);

%If these were from multiple files, separate
if isfield(inst, 'file')
    nams = {inst.file};
    [uu, ~, ic] = unique(nams);
    nfil = max(ic);
    for i = nfil:-1:1
        out(i).name = uu{i};
        out(i).tps = tpcrp( ic == i );
    end
else
    out.name = '';
    out.tps = tpcrp;
end

if opts.verbose
    figure
    xx = (-opts.wid(1) : opts.wid(2) );
    subplot(2, 1, 1), hold on
    %Plot trace snippets
    cellfun(@(x)plot(xx,x), tpcrp)
    %Plot line at bottom and top
    plot( [xx(1) xx(end)] , [0 0], 'r', 'LineWidth', 1)
    plot( [xx(1) xx(end)] , opts.pwlcc * [1 1], 'g', 'LineWidth', 1)
    %plot 'median' one
    medtr = median( reshape( [tpcrp{:}], length(tpcrp{1}), [] ), 2);
    plot(xx, medtr, 'k', 'LineWidth', 2)
    xlim(opts.wid.*[-1 1])
    yl = [ min(medtr) max(medtr) ] + range(medtr) * 0.5 .* [-1 1];
    ylim(yl)
    
    %Plot histogram
    subplot(2,1,2), hold on
    [y, x] = nhistc( [tpcrp{:}], 0.1 );
    plot(x,y)
    xlim(yl)
end