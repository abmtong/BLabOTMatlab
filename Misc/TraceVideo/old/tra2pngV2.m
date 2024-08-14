function tra2pngV2(filein, fileout, outsize, zoom, timeInds, filteropts)
%V2: Plot every point, so showing at 60FPS = 24% speed

addpath('C:\Users\Alexander Tong\Box Sync\Year 2 Semester 2\Res\MATLAB')
startup

% filein: forceextension*.mat to open
% fileout: prefix and foldername for filess, .\*\*#.png
% outsize: [x, y] (px)
% zoom: [x,y] (time, contour)
% timeInds: start, end time for plotting

%Might do both ForTim and ConTim, maybe even in same figure

if nargin < 1 || isempty(filein)
    [f, p] = uigetfile('ForceExtension*.mat');
    if ~p
        return
    end
    filein = [p f];
end
if nargin<2 || isempty(fileout)
    fileout = 'tra2png';
end
if nargin<3 || isempty(outsize)
    outsize = [960 540];
end
if nargin<4 || isempty(zoom)
    zoom = [1, 200];
end
if nargin<5 || isempty(timeInds)
    timeInds = [0 10]; %plot 10s
end
if nargin<6 || isempty(filteropts)
    filteropts = {@mean, [], 10};
end

%Set up figure
fig = figure('Name','PrintWindow');
fig.Position = [0 0 outsize];
ax1 = subplot(3,1,[1 2]);
hold on
ax2 = subplot(3,1,3);
hold on

%Load ForceExtension file
load(filein,'ContourData');
t = ContourData.time;
x = ContourData.extension;
f = ContourData.force;

%XWLC for Contour to Extension
    function outXpL = XWLC(F, P, S, kT)
        %Simplification var.s
        C1 = F*P/kT;
        C2 = exp(nthroot(900./C1,4));
        outXpL = 4/3 ...
            + -4./(3.*sqrt(C1+1)) ...
            + -10*C2 ./sqrt(C1) ./(C2-1).^2 ...
            + C1.^1.62 ./ (3.55+ 3.8* C1.^2.2) ...
            + F./S;
    end
PL = 60;
SM = 550;
kT = 4.14;
BP = .34;
c = x ./ XWLC(f, PL, SM, kT) / BP;

%Crop
ikeep = t>timeInds(1) & t < timeInds(2);
t0 = t(ikeep);
f0 = f(ikeep);
c0 = c(ikeep);

%Filter
t = windowFilter(filteropts{1},t0,filteropts{2:end});
f = windowFilter(filteropts{1},f0,filteropts{2:end});
c = windowFilter(filteropts{1},c0,filteropts{2:end});
len = length(t);
t = t-t(1);

%Make output folder
if ~exist(fileout, 'dir')
    mkdir(fileout)
end

%Might want to work with non-feedback cycle'd data
color = 'k';
twin = [-zoom(1) 0];
cwin = [0 zoom(2)] - zoom(2)/10;
csm = smooth(c, 15); %Camera follows smoothened C to mitigate jitter

%Set Contour ticks
ctick = ceil(zoom(2)/100)*10; %About 10 ticks on Y-axis, closest multiple of 10
cmin = floor((min(c)-zoom(2))/ctick)*ctick;
cmax = ceil((max(c)+zoom(2))/ctick)*ctick;
ct = cmin:ctick:cmax;
ctl = arrayfun(@(x)num2str(x,'%0.0f'), ct, 'UniformOutput', false);
ax1.YTick = ct;
ax1.YTickLabel = ctl;

%Set Time ticks
tmin = t(1); %=0
tmax = t(end);
ttick = 0.1;
xt = tmin:ttick:tmax+ttick;
xtl = arrayfun(@(x)num2str(x,'%0.1f'), xt, 'UniformOutput', false);
ax1.XTick = xt;
ax1.XTickLabel = xtl;
ax2.XTick = xt;
ax2.XTickLabel = xtl;

%Set axis labels
ax1.YLabel.String = 'Contour(bp)';
ax2.YLabel.String = 'Force(pN)';
ax2.XLabel.String = 'Time(s)';

%Plot
plot(ax1, t,c,'Color',color)
plot(ax1, t0,c0,'Color',[.7 .7 .7])
plot(ax2, t, f, 'Color', color)
ylim(ax2, [5 15]);

%Scale factor, multiple of 540p
scale = 1;
startT = tic;
for i = 1:len
    %Shift window bounds to simulate motion
    xlim(ax1, t(i) + twin)
    xlim(ax2, t(i) + twin)
    ylim(ax1,csm(i) +cwin)
    
    %Print the figure
    print(fig, sprintf('.\\%s\\%s%0.4d',fileout,fileout,i),'-dpng',sprintf('-r%d',96*scale))
    %For 540p>1080p, -r192 works - seems like dpi setting outputs a "10inx10in" canvas
    %That is, equal pixels is -r(Xdim/10), scales linearly
end
close(fig)
fprintf('tra2png finished in %0.2fm\n', toc(startT)/60)
end