function out = plotRestarts(rs, frcrng)

%Restart struct with fields {ind, islong, frc, fp}

Fs = 4000/3;

if nargin < 2
    frcrng = [4 6 10 13 17 25];
end

if isstruct(rs) && isscalar(rs)
    rs = struct2cell(rs);
    rs = [rs{:}];
end

dws = cellfun(@(x) diff(x(:)')/Fs, {rs.ind}, 'Un', 0);
dws = [dws{:}];
frcs = [rs.frc];
longs = [rs.islong];

%Plot dw-frc scatter, colored by longs
figure
subplot(2,1,1)
scatter(frcs, dws, [], longs)
colormap jet
colorbar
yl = ylim;
arrayfun(@(x) line([x x], yl), frcrng)
xlabel('Force (pN)')
ylabel('Restart Time (s), red = break')

%Plot ccdf by frcrng
nf = length(frcrng)-1;
dwfs = cell(1, nf);
fs = zeros(1,nf);
biexpfits = cell(1,nf);
biexpfitsci = cell(1,nf);
biexp = nexpdist(2,2); %Biexp function
bigu = [.1 .1 .01] ; %Standard guess of [k1 a2 k2] {a1 = 1}
mleopts = statset('MaxFunEvals', 1e6, 'MaxIter', 1e6);
frcid = zeros(1, length(dws));
for i = 1:nf
    ki = frcs >= frcrng(i) & frcs < frcrng(i+1);
    frcid(ki) = i;
    d = dws(ki);
    d(logical(longs(ki))) = inf;
    dwfs{i} = d;
    fs(i) = mean(frcs(ki));
    
    %Fit to biexp
    [biexpfits{i}, biexpfitsci{i}] = mle(dws(ki), 'pdf', biexp.pdf, 'cdf', @(x,k1,a2,k2) 1-biexp.cdf(x,k1,a2,k2), 'start', bigu, 'LowerBound', biexp.lb, 'UpperBound', biexp.ub, 'Censoring', logical(longs(ki)), 'Options', mleopts);
end

pcc = @(x,y) surface( repmat(sort(x), [2 1]), repmat( (length(x):-1:1) / length(x), [2 1]), zeros(2,length(x)), y*ones(2,length(x)) , 'EdgeColor', 'interp', 'LineWidth', 2 );
ax2 = subplot(2,1,2);
hold on
cellfun(pcc, dwfs, num2cell(fs))
set(gca, 'YScale', 'log')
legend(arrayfun(@(x) sprintf('%0.1fpN', x), fs, 'Un', 0))
axis tight
xlabel('Restart Time (s)')
ylabel('CCDF (arb.)')
colormap jet
colorbar

%Reset color order index, plot biexps as dashes -- ignore, using colormap instead
% ax = gca;
% ax.ColorOrderIndex = 1;

%Plot biexps
xl = xlim;
xx = linspace(xl(1),xl(2), 1e3);
for i = 1:nf
    ft = num2cell(biexpfits{i});
%     plot(xx, biexp.cdf(xx, ft{:} ), '--' ) 
%     surface( repmat(xx, [2 1]), repmat( biexp.cdf(xx, ft{:}), [2 1]), zeros(2,length(xx)), fs(i)*ones(2,length(xx)) , 'EdgeColor', 'interp', 'LineStyle', '--' )
end

%Convert a1-less biexp to a1-having 
fts = cell(1,nf);
ftsci = cell(1,nf);
for i = 1:nf
    tmp = [1 biexpfits{i}];
    scl = sum(tmp(1:2:end));
    tmp(1:2:end) = tmp(1:2:end)/scl;
    fts{i} = tmp;
    tmp2 = biexpfitsci{i}(2,:) - biexpfits{i};
    tmp2 = [sqrt( sum( tmp2(2:2:end).^2) ) tmp2]; %#ok<AGROW>
    tmp2(1:2:end) = tmp2(1:2:end)/scl;
    ftsci{i} = tmp2;
end



%And restart%

%Assemble output structure
out = struct('frc', num2cell(fs), 'dws', dwfs, 'fit', fts, 'fitci', ftsci);

%Okay this is real messy, but whatever

%Plot stats per force range
if ~any(longs)
    figure
    dwfrcs = arrayfun(@(x,y) ones(1,x) * y, cellfun(@length, dwfs), fs, 'Un', 0);
    beeswarm([dwfrcs{:}]', [dwfs{:}]', 'corral_style', 'random', 'dot_size', .5, 'overlay_style', 'mad', 'colormap', 'jet');
    ylabel('Restart time (s)')
    xlabel('Restart Force (pN)')
end

%Repeat with non-restarts removed
if any(longs)
    drawnow
    ki = cellfun(@(x)isequal(x, 0), {rs.islong});
    plotRestarts(rs(ki), frcrng)
end

%Plot bar of pause %
if any(longs)
    rschc = zeros(1,length(fs));
    ns = zeros(1,length(fs));
    for i = 1:length(fs)
        l = longs(frcid == i);
        ns(i) = length(l);
        rschc(i) = 1 - sum(l) / ns(i);
    end
    %Get colors
    cmap = colormap(ax2);
    %Get clim
    cl = ax2.CLim;
    cint = linspace(cl(1), cl(2), size(cmap, 1));
%     cint = cint(1:end-1);
    %Interp the color
    col = cellfun(@(x) interp1( cint', cmap, x ), num2cell(fs), 'Un', 0); 
    
    figure, hold on
    for i = 1:length(fs)
        bar(fs(i), rschc(i), 'FaceColor', col{i})
    end
%     figure, bar(fs, rschc), hold on
    errorbar(fs, rschc, sqrt(rschc)./sqrt(ns), 'LineStyle', 'none') 
    xlabel('Restart Force (pN)')
    ylabel('Restart Chance')
end

%Fit to arrhenius, linear + linear+flat
%ln(t_restart) = -Fdx + ln(C)
medrsts = zeros(1,nf);
medfrcc = cell(1,nf);
medrstsraw = cell(1,nf);
medrstslsd = zeros(1,nf);
q1 = zeros(1,nf);
q3 = zeros(1,nf);
for i = 1:nf
     tmp = out(i).dws;
     tmp(isinf(tmp)) = [];
     medrsts(i) = median(tmp);
     medrstsraw{i} = tmp;
     medrstslsd(i) = std(log(tmp));
     q1(i) = prctile(tmp, 25);
     q3(i) = prctile(tmp, 75);
end

figure('Name', 'Arrhenius fitting')
% plot(fs, log(medrsts), 'ok')
errorbar(fs, log(medrsts), medrstslsd, 'LineStyle', 'none'); %SD
% errorbar(fs, log(medrsts), log(q1), log(q3), 'Marker', 'o', 'LineStyle', 'none'); %Quartile
ylabel('log(t_{restart})')
xlabel('Force (pN)')
hold on

%REMOVE 5pN PT AS OUTLIER
rmi = fs>5 & fs < 6;
fs(rmi) = [];
medrsts(rmi) = [];
warning('Removed 5pN point from fitting')

%Linear fit: polyfit
pf = polyfit(fs, log(medrsts),1);
xx = linspace(0,max(fs)*1.1, 101);
yy = polyval(pf, xx);
plot(xx,yy)
%Display eqn
text(1, log(median(medrsts)), sprintf('[m,b] = [%0.2f,%0.2f]', -pf(1)*4.14, exp(pf(2))))

%Linear + flat fit
fitfcn = @(x0,x) (x0(1)*x + x0(2)) .* (x<x0(3)) + (x>=x0(3)) .* ( x0(3) * x0(1) + x0(2));
[ft, ~, rsd, ~, ~, ~, jcb] = lsqcurvefit(fitfcn, [pf 10], fs, log(medrsts) );
%95% CI interval of fits
ci = nlparci( nlinfit( fs, log(medrsts) , fitfcn, ft) , rsd,'Jacobian',jcb);


%Join fit vals + CIs
ci = [ft(:) ci];
%Scale CI: slope to pNnm, log(time) to time
ci(1,:) = ci(1,:) * -4.14;
ci(2,:) = exp(ci(2,:));
out = ci;

plot(xx, fitfcn(ft, xx))
text(1, log(median(medrsts))-0.5, sprintf('[dx,t0,xmax] = [%0.2f,%0.2f,%0.2f]', -ft(1)*4.14, exp(ft(2)), ft(3)))


%% Maybe switch to fitting individual points instead of medians ?


