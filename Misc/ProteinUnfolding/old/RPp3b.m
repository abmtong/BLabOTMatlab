function out = RPp3b(inst, inOpts)
%Calc rip transition path histogram

opts.fil = 10; %Filter (smooth, dont downsample)
% opts.meth = 1; %Window method
opts.wid = [200 200]; %Pts to take on each side of the rip

opts.pwlcc = 0.35*106; %Protein size (nm)
% opts.pwlcfudge = 1; %Protein size offset, nm

opts.usetfpbe = [1 1]; %Uses tfpbe1 and tfpbe2, if they exist (see RPpickbyeyeGUI). Make [0 0] to disable

opts.verbose = 1; %Debug plots

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


len = length(inst);
tpcrp = cell(1,len);
tpcrpr = cell(1,len);
for i = 1:len
    %Get protein contour
    tmp = inst(i);
    yy = double( tmp.conpro );
    
%     %Deconvolve protein contour?
%     convthing = exp(-(0:opts.convpts)/opts.convpts(2));
%     %Normalize
%     convthing = convthing / sum(convthing);
    
    %Filter
    yf = windowFilter(@mean, yy, opts.fil, 1);
    %Crop
    irng = tmp.ripind - opts.wid (1) : tmp.ripind + opts.wid(2);
    if any(irng < 1 | irng > length(yf))
        %Skip this one
        tpcrp{i} = inf;
        tpcrpr{i} = inf;
        continue
    end
    yc = yf(irng);
    ycr= yy(irng);
    
    %Save
    tpcrp{i} = yc;
    tpcrpr{i} = ycr;
end
%Remove empty entries if they were skipped
ki1 = ~cellfun(@isempty, tpcrp);

%Remove entries with wild outliers
ki2 = ~ (cellfun(@(x) max(abs(x)), tpcrpr) > opts.pwlcc * 100);

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

ki = ki1 & ki2 & ki3;
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
        out(i).tpsr = tpcrpr( ic == i );
    end
else
    out.name = '';
    out.tps = tpcrp;
    out.tpsr = tpcrpr;
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