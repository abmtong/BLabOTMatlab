function gatherresults(in, infp, tilt)

if nargin < 2 || isempty(infp)
    [f, p] = uigetfile('C:\Users\Alexander Tong\Box Sync\Res\Japan - Electrorotation\Data\','Select a file with the right prefix MMDDYYA###.mat');
    infp = fullfile(p, f);
end

if nargin < 3
    tilt = 0;
end

if length(in) ~= 7
    error('Requires 7 filenum inputs')
end
%Input: 1x7 vector: [raw prot cal desH desS conH conS]
% Output:
% HeatMap Protocol HyNai SynNai
% Cal     AngHist  HyDes SynDes

opts.tdratio = 10; %[ATP/ADP]
opts.kT = 4.14; %pnNm

[path, f, e] = fileparts(infp);
path = [path filesep];
f = f(1:end-3); %strip the 3 numbers at the end of the filename

files = arrayfun(@(x) sprintf('%s%03d%s', f, x, e),in,'Un',0);

%Later on, with half-half des/nai, these will have the same number
if in(4) == in(6)
    files{4} = [files{4}(1:end-4) 'a' e];
    files{6} = [files{6}(1:end-4) 'b' e];
end
if in(5) == in(7)
    files{5} = [files{5}(1:end-4) 'a' e];
    files{7} = [files{7}(1:end-4) 'b' e];
end

fg = figure('Name', sprintf('%s with protocol %03d, full in [%d %d %d %d %d %d %d]', files{1}, in(2),in));

ax1 = subplot2(fg, [2 4], 1);
eldata1 = load([path files{1}]);
eldata1 = eldata1.eldata;
%plot heatmap, code taken from ElRoGUI
%Plot centroid image
%plot 99th - 1st percentile, to remove outliers
xx = eldata1.x;
yy = eldata1.y;
trimpct = .5;
xl = prctile(xx, [0 100] + [1 -1] * trimpct);
yl = prctile(yy, [0 100] + [1 -1] * trimpct);
ki = xx > xl(1) & xx < xl(2) & yy > yl(1) & yy < yl(2);
[hc, hx, hy] = histcounts2(xx(ki), yy(ki), 50);
hx = hx(1:end-1) + median(diff(hx))/2;
hy = hy(1:end-1) + median(diff(hy))/2;
srf = pcolor(ax1, hx, hy, hc');
%Label centroid, plotted by same method. Here it's just the center of the screen.
hold(ax1, 'on')
plot(ax1, mean(xl), mean(yl), '+', 'Color', [1 1 1], 'MarkerSize', 4)
srf.EdgeColor = 'none';
srf.FaceColor = 'interp';
xlim(ax1, xl)
ylim(ax1, yl)
axis(ax1, 'ij')
axis(ax1, 'square')
box(ax1, 'off')
ax1.YDir = 'normal';
ax1.XColor = [1 1 1];
ax1.YColor = [1 1 1];
ax1.XTickLabel = [];
ax1.YTickLabel = [];
%Normalize the color a bit
cmax = max(1,prctile(hc(:), 95));
ax1.CLim = [0 cmax];
title(ax1, 'Position Histogram')

%Plot protocol, if supplied
if in(2) >= 1
    ax3 = subplot2(fg, [2 4], 3); hold on
    eldata2 = load([path files{2}]);
    eldata2=eldata2.eldata;
    if eldata2.inf.Mode == '-'
        prinf.dir = 'NA';
        if isfield(eldata2,'prot')
            plot(eldata2.prot(:,1)/360, eldata2.prot(:,2),'k')
        end
    else
    prinf = procparams(eldata2);
    protopts.verbose = 0;
    [~, protraw] = getProtocol(eldata2, protopts);
    scatter(ax3,mod(protraw.trappos(protraw.isodd), 1), protraw.zetas(protraw.isodd).^-.5, 'MarkerEdgeColor', [0    0.4470    0.7410]);
    scatter(ax3,mod(protraw.trappos(~protraw.isodd), 1), protraw.zetas(~protraw.isodd).^-.5,'*', 'MarkerEdgeColor', [0    0.4470    0.7410]);
    errorbar(ax3,protraw.trappos1, circsmooth(protraw.prot1,3), protraw.prot1sd ./ protraw.prot1n, 'b');
    axis(ax3, 'tight')
    xlim(ax3, [0 1])
    if isfield(eldata2,'prot')
        plot(eldata2.prot(:,1)/360, eldata2.prot(:,2) * median(protraw.prot1),'k')
    end
    switch prinf.dir
        case 'Hydrolysis'
            title(ax3, 'Protocol (Hy)')
        case 'Synthesis'
            title(ax3, 'Protocol (Syn)')
        otherwise
            title(ax3, 'Protocol (??)')
    end
    end
else
    prinf.dir = '00';
end

%Plot angular histogram, code taken from @ElRoGUI
ax2 = subplot2(fg, [2, 4], 4);
thbin = 4; %thbin must divide 120
[pth, x] = angularhist(eldata1.x, eldata1.y, thbin);
plot(ax2, x/pi*180,pth/max(pth)) %Angular hist given by x/y pos
hold on
%Negate to account for sign differences in RotTra and angularhist
p2 = histcounts(mod(-eldata1.rotlong,1), [0 (x+thbin/2/180*pi)/2/pi]);
plot(ax2, x/pi*180,p2/max(p2)) %Angular hist given by rotlong
axis(ax2, 'tight')
title(ax2, 'Angular Histogram')

%Calculate cal, plot powspec as measure of quality
if in(4) >=0
    ax4 = subplot2(fg, [2 4], 2);
    eldata3 = load([path files{3}]);
    eldata3=eldata3.eldata;
    calopts.verbose = 0;
    cropfp = sprintf('%s\\CropFiles%s\\%s.crop', path, '', files{3}(1:end-4));
    fid = fopen(cropfp);
    if fid ~= -1
        cropT = textscan(fid, '%f');
        cropT = cropT{1};
        calopts.ttrim = cropT;
        fclose(fid);
    end
    cal = CalElro(eldata3, calopts);
    loglog(ax4, cal.Fb, cal.Pb);
    line(ax4, cal.params.modf * [.9 1.1], cal.cf*[1 1], 'Color', 'r')
    axis(ax4, 'tight')
    text(cal.Fb(1), mean(ax4.YLim), sprintf('C(f_0): %0.2f \n k: %0.2f pNnm/rad^2', cal.cf, cal.k))
    title(ax4, 'Calibration')
else
    cal = [];
    cal.k = 1;
end
%Calculate works, if number specified (~= -1)
workopts.k = cal.k;
workopts.chambertilt = tilt;
workopts.path = path;
% tits = { 'Op Hy' 'Opt Syn' 'Nai Hy' 'Nai Syn' };
for i = 4:7
    if in(i) > 0
        ax = subplot2(fg, [2 4], i+1);

        eld = load([path files{i}]);
        eld = eld.eldata;
        prms = procparams(eld.inf);
        switch eld.inf.Mode
            case 'Designed'
                md = 'Opt';
            case {'Constant Speed', 'Constant Velocity'} %Some 
                md = 'Nai';
        end
        %New files have correct metadata, so use it to name graph
        if str2double(eld.inf.Date) > 20190829
            title(ax, sprintf('%s %s', md, prms.dir(1:3)))
        else %old data, need to swap syn and hy
            if strcmp(prms.dir, 'Synthesis')
                dr = 'Hyd';
            elseif strcmp(prms.dir,'Hydrolysis')
                dr = 'Syn';
            end
            title(ax, sprintf('%s %s', md, dr))
        end
        CalcWork(eld, [], workopts);
        wkfg = gcf;
        wkax = wkfg.Children(end);
        copyobj(wkax.Children, ax);
        delete(wkfg);
        axis(ax, 'tight')
    end
end

% %Energy of one ATP hydrolysis, pNnm
% %30.5kJ/mol -> pnNm
% atp = -30.5e3/6.02e2 + opts.kT * log(tdratio * 1e-3);%G = G0 + kTlnQ with [Pi] = 1e-3
% %about -69.7pN nm for kT = 4.14 tdr = 10; hence -209.1 per rotation

fg.Position = [0 0 1920 1080];
folnam = 'gr2';
if ~exist(folnam, 'dir')
    mkdir(folnam)
end
figfname = sprintf('.\\%s\\E%sP%03dD%03d%03d%03d%03d', folnam, files{1}(1:end-4), in(2), in(4), in(5), in(6), in(7));
savefig(fg, figfname)
print(fg, figfname, '-dpng', '-r96')
