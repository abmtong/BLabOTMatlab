function outProtocol = getProtocolV2(indat, inOpts)
%Considered trying a different method that didn't have so many calls to lsqcurvefit
%Results are worse, so meh

if nargin < 1 || isempty(indat)
    [f, p]= uigetfile('*.mat');
    if ~p
        return
    end
    load(fullfile(p, f))
    indat = eldata;
elseif ischar(indat)
    load(indat)
    indat = eldata;
end

% opts.stepsz = 12; %deg, for each step.
% opts.tdwell = 1; %s, for each dwell
opts.cropt = [0 inf];
opts.cropstr = '';
opts.toff = 0; %s, offset between data and transition
opts.ttrim = [.05 0.01]; %s, time to trim from each side
opts.circacorr = 0; %whether to use circular acorr or not
opts.verbose = 1; %wether to plot the output or not
opts.outrottime = 1; %s, use 1 for easy scaling to higher times
opts.zetafitexp = 1; %whether to fit the acorr to an exp or just sum
opts.zetafittmax = 0.01; %maximum t to fit/sum to in acorr

if nargin > 1 && ~isempty(inOpts)
    opts = handleOpts(opts, inOpts);
end

%extract for easiness
tim = indat.time;
rot = indat.rotlong;
Fs = indat.inf.FramerateHz;

params = procparams(indat.inf.Mode, indat.inf.Parameters);
opts.tdwell = params.tdwell;
opts.stepsz = params.stepsz;
opts.rotdir = 2*strcmp('Hydrolysis', params.dir) -1; %+ for hy, - for syn

dwlen = floor(Fs * opts.tdwell);

%make start, end indicies for dwells
len = length(tim);
indSta = (ceil(opts.toff *Fs):dwlen:len) + ceil(opts.ttrim(1) * Fs);
%cut first and last, bc first has a big move, last might be incomplete
indSta = indSta(2:end-1);
slen = length(indSta);

%Gather dwells, and their resulting acorr and zetas (frictions)
dws = cell(1,slen);
acrs = cell(1, slen);
zetas = zeros(1, slen);

dwlencr = floor((opts.tdwell - sum(opts.ttrim)) * Fs);
%Set up lsqcurvefit stuff
if opts.zetafitexp
    %Acorrs are a negative exponential(?), can fit that and then integrate
    %f = Aexp(-bx)
    fitfcn = @(x0,x) x0(1) * exp(-x0(2) * x);
    lsqopts = optimoptions('lsqcurvefit');
    lsqopts.Display = 'none';
end
x = (0:dwlencr-1) /Fs;
twin = x<opts.zetafittmax;
x = x(twin);

for i = 1:slen
    dws{i} = rot(indSta(i):indSta(i) +dwlencr-1);
    if opts.circacorr
        out = zeros(1, dwlencr);
        for j = 1:dwlencr
            out(j) = circshift(dws{i}, [0,j-1]) * dws{i}';
        end
        acrs{i} = out;
    else
        xc = xcorr(dws{i}-mean(dws{i}));
        acrs{i} = xc(dwlencr:end); %want the end half that's the same length as dwlencr
    end
end

%Get positions of dwells
rotpos = cellfun(@mean, dws);
%Get positions of trap, in rev.s
trappos = (1:length(rotpos)) * opts.rotdir * opts.stepsz /360;
%The bead can slip and then be in the other side of the trap: account for this
%Check which side of the trap the bead is closer to
% Subtract bead pos and trap pos, see if this is an integer or half-integer
isodd = logical(mod( round((rotpos - trappos) * 2) , 2));
trappos(isodd) = trappos(isodd) + 0.5;

%keep those in cropt
tcropind = opts.cropt * Fs;
kit = indSta > tcropind(1) & indSta + dwlencr < tcropind(2);
%And reject dwells where it's moving
rngs = cellfun(@range, dws);
ki = rngs<0.5 & kit;
%Apply to crop to the variables
dws = dws(ki);
rotpos = rotpos(ki);
trappos = trappos(ki);
isodd = isodd(ki);
acrs = acrs(ki);

%Integrate acorr by fitting exp; average together pts and fit the averaged acorr
[utrappos, ~, utpinds] = uniquetol(mod(trappos, 1), eps(max(abs(trappos)))*10);
len = length(utrappos);
uacorr = cell(1,len);

for i = 1:len
    %Gather cells, average together, fit
    uacorr{i} = median( reshape( [acrs{utpinds == i}], dwlencr, [] ), 2)';
    if opts.zetafitexp
        fit = lsqcurvefit(fitfcn, [mean(uacorr{i}) uacorr{i}(1)], x, uacorr{i}(twin), [], [], lsqopts);
        %The integral of this is A/b
        zetas(i) = fit(1)/fit(2);
    else %or just sum the acorr we have
        zetas(i) = sum(uacorr{i}(twin)) / Fs;
    end
end

%Average by spin
[trappos1, zetas1, zetas1sd, zetas1n] = splitbymodn(trappos, zetas, 1);
[~, prot1, prot1sd, prot1n] = splitbymodn(trappos, zetas.^-.5, 1);

%Average by triad
[trappos3, zetas3, zetas3sd, zetas3n] = splitbymodn(trappos, zetas, 1/3);

%Calculate protocol
outProtocol = vel2prot(trappos3, 1./sqrt(zetas3), 2);
outProtocol(:,1) = outProtocol(:,1)*opts.outrottime;

%Plot if verbose
if opts.verbose
%     %plot raw data
%     figure('Name', 'Raw Data')
%     %plot full trace
%     subplot(1,2,1)
%     plot(tim, rot)
%     %Add lines showing boundaries
%     yl = ylim;
%     for i = 1:slen
%         line(tim(indSta(i)) * ones(1,2), yl, 'Color', 'g')
%         line(tim(indSta(i)+dwlencr) * ones(1,2), yl, 'Color', 'r')
%     end
%     %plot sections
%     subplot(1,2,2)
%     hold on
%     cellfun(@(x)plot((0:dwlencr-1) / Fs, x), dws)
    
    %plot acorrs
%     figure('Name', 'Acorrs')
%     hold on
%     cellfun(@(x)plot((0:dwlencr-1) / Fs, x), acrs(ki))
%     xlim([0 opts.zetafittmax])
    
    %plot gammas as a fnc of 
    
%     %plot protocol velocities and then protocol(theta) mod 1/3
%     figure('Name', 'Protocol')
%     ax=subplot(2,2,[1 2]);
%     set(ax, 'YScale', 'log')
%     hold on
%     %plot three quadrants as different colors
%     tol = eps(max(rotpos));
%     mrp = mod(rotpos(si),1)+tol;
%     ki1 = mrp > 0 & mrp < 1/3;
%     scatter(mod(rotpos(ki1), 1/3), 1./sqrt(zetas(ki1)), 'r');
%     ki2 = mrp > 1/3 & mrp < 2/3;
%     scatter(mod(rotpos(ki2),1/3), 1./sqrt(zetas(ki2)), 'g');
%     ki3 = mrp > 2/3 & mrp < 1;
%     scatter(mod(rotpos(ki3),1/3), 1./sqrt(zetas(ki3)), 'b');
%     %plot averaged together
%     errorbar(rotpos3, 1./sqrt(zetas3), zetas3sd, 'k', 'LineWidth', 1)
%     ax1= axes('Position', [.075 .975-.225 .9 .225]);
%     hold on
%     %separate by isodd and by triad
%     triad = mod(floor(trappos * 3),3);
%     scatter(mod(trappos(isodd&triad == 0), 1), (zetas(isodd&triad == 0)), 'r');
%     scatter(mod(trappos(~isodd&triad == 0), 1),(zetas(~isodd&triad == 0)), 'r*');
%     errorbar(trappos1, zetas1, zetas1sd./sqrt(zetas1n), 'k', 'LineWidth', .5)
%     ax2= axes('Position', [.075 .975-2*.225 .9 .225]);
%     hold on
%     scatter(mod(trappos(isodd&triad == 1), 1)-1/3, (zetas(isodd&triad == 1)), 'g');
%     scatter(mod(trappos(~isodd&triad == 1), 1)-1/3, (zetas(~isodd&triad == 1)), 'g*');
%     errorbar(trappos1-1/3, zetas1, zetas1sd./sqrt(zetas1n), 'k', 'LineWidth', .5)
%     ax3= axes('Position', [.075 .975-3*.225 .9 .225]);
%     hold on
%     scatter(mod(trappos(isodd&triad == 2), 1)-2/3, (zetas(isodd&triad == 2)), 'b');
%     scatter(mod(trappos(~isodd&triad == 2), 1)-2/3, (zetas(~isodd&triad == 2)), 'b*');
%     errorbar(trappos1-2/3, zetas1, zetas1sd./sqrt(zetas1n), 'k', 'LineWidth', .5)
%     
%     ax4= axes('Position', [.075 .975-4*.225 .9 .225]);
%     hold on
%     scatter(mod(trappos(isodd&triad == 0), 1/3), (zetas(isodd&triad == 0)), 'r');
%     scatter(mod(trappos(~isodd&triad == 0), 1/3), (zetas(~isodd&triad == 0)), 'r*');
%     scatter(mod(trappos(isodd&triad == 1), 1/3), (zetas(isodd&triad == 1)), 'g');
%     scatter(mod(trappos(~isodd&triad == 1), 1/3), (zetas(~isodd&triad == 1)), 'g*');
%     scatter(mod(trappos(isodd&triad == 2), 1/3), (zetas(isodd&triad == 2)), 'b');
%     scatter(mod(trappos(~isodd&triad == 2), 1/3), (zetas(~isodd&triad == 2)), 'b*');
%     errorbar(trappos3, zetas3, zetas3sd./sqrt(zetas3n), 'k', 'LineWidth', 1)
% 
%     axs = [ax1 ax2 ax3 ax4];
%     arrayfun(@(x)axis(x, 'tight'), axs)
%     arrayfun(@(x)set(x, 'YScale', 'log'), axs)
%     arrayfun(@(x)set(x, 'XLim', [0 1/3]), axs)
%     linkaxes(axs, 'x')
    
    figure('Name', 'Protocol all')
    %plot together
    ax= subplot(2,1,1);
    hold on
    scatter(mod(trappos(isodd), 1), zetas(isodd).^-.5,'b');
    scatter(mod(trappos(~isodd), 1), zetas(~isodd).^-.5,'b*');
	errorbar(trappos1, circsmooth(prot1,3), prot1sd ./ prot1n, 'k');

    %     errorbar(trappos1, zetas1.^-.5, zetas1sd.^-.5./sqrt(zetas1n), 'k');
    xlim(ax, [0 1])
    %Plot angular histogram, taken from @ElRoGUI
    ax=subplot(2,1,2);
    
    thbin = 4; %thbin must divide 120
    [p, x] = angularhist(indat.x, indat.y, thbin);
    plot(x/2/pi,p/max(p))
    hold on
    p2 = histcounts(mod(rot,1), [0 (x+thbin/2/180*pi)/2/pi]);
    plot(x/2/pi,p2/max(p2))
    axis(ax, 'tight')
    %Find most probable 3-fold rotation axis
    p2sm = circsmooth(p2, 5);
    p2sm = sum(reshape(p2sm, [], 3), 2);
    [~, maxi] = max(p2sm);
    yl = ylim;
    xs = x(maxi);
    xs = xs/2/pi + [0 1/3 2/3];
    arrayfun(@(x)line( x * [1 1], yl, 'Color', [0.8500 0.3250 0.0980] ), xs); %Second color of @lines
    
    %Plot zetas, too; they should coincide
    plot(trappos1, circsmooth(zetas1/max(zetas1),3), 'g');
    
    %Does e.g. gamma correspond to places of residence? Should plot that also.
    %For not exactly 3-fold symmetric, can I rescale to squish some / enlarge other triads?
end
