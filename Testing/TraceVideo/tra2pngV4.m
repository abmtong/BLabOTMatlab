function tra2pngV4(filein, fileout, outsize, zoom, timeInds, filteropts, tfstepfind, toprint)
%V2: Plot every point, so filter10, 62.5FPS = 1/4 speed
%V3: Plot squished (about x-axis), better use of whitespace
%V4: Now left half of top plot is w/ stepfinding

% filein: forceextension*.mat to open
% fileout: prefix and foldername for filess, .\*\*#.png
% outsize: [x, y] (px)
% zoom: [x,y] (time, contour)
% timeInds: start, end time for plotting

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
    outsize = [400 540];
end
if nargin<4 || isempty(zoom)
    zoom = [.5, 100];
end
if nargin<5 || isempty(timeInds)
    timeInds = [0 10]; %plot 10s
end
if nargin<6 || isempty(filteropts)
    filteropts = {@mean, [], 10};
end
if nargin<7 || isempty(tfstepfind)
    tfstepfind = true;
end
if nargin<8 || isempty(toprint)
    toprint = 0;
end

%Set up figure and axes
fig = figure('Name','PrintWindow');
fig.Position = [0 0 outsize];
ax1 =  axes('Position', [.15 .35 .80 .60]);
hold (ax1,'on')
ax1.ClippingStyle = 'rectangle';
%ax1b is overlaid on ax1
ax1b = axes('Position', [.15 .35 .40 .60]);
hold(ax1b, 'on')
ax1b.ClippingStyle = 'rectangle';
ax1b.XTickLabels = {};
ax1b.YTickLabels = {};
ax2 =  axes('Position', [.15 .1 .80 .2]);
hold (ax2,'on')

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
PL = 40;
SM = 400;
kT = 4.14;
BP = .34;
c = x ./ XWLC(f, PL, SM, kT) / BP;

%Crop
ikeep = t>timeInds(1) & t < timeInds(2);
t0 = t(ikeep);
f0 = f(ikeep);
c0 = c(ikeep);
t0 = t0-t0(1);

%Filter
t = windowFilter(filteropts{1},t0,filteropts{2:end});
f = windowFilter(filteropts{1},f0,filteropts{2:end});
c = windowFilter(filteropts{1},c0,filteropts{2:end});
len = length(t);
%t = t-t(1);

%Make output folder
if toprint && ~exist(fileout, 'dir')
    mkdir(fileout)
end

%Misc options, incl window size helpers
color = 'k';
twin = [-zoom(1) 0];
twinb = [-zoom(1) -zoom(1)/2];
cwin = [0 zoom(2)] - zoom(2)/10;
csm = smooth(c, 25); %Camera follows smoothed c to mitigate jitter

%Set Contour ticks
ctick = ceil(zoom(2)/100)*10; %Aim for 10 ticks on Y-axis, closest multiple of 10
cmin = floor((min(c)-zoom(2))/ctick)*ctick;
cmax = ceil((max(c)+zoom(2))/ctick)*ctick;
ct = cmin:ctick:cmax;
ctl = arrayfun(@(x)num2str(x,'%0.0f'), ct, 'UniformOutput', false);
ax1.YTick = ct;
ax1.YTickLabel = ctl;

%Set Time ticks
tmin =0;
tmax = t(end);
ttick = 0.1;
xt = tmin:ttick:tmax+ttick;
xtl = arrayfun(@(x)num2str(x,'%0.1f'), xt, 'UniformOutput', false);
ax1.XTick = xt;
ax1.XTickLabel = xtl;
ax1b.XTick = xt;
ax2.XTick = xt;
ax2.XTickLabel = xtl;

%Set axis labels
ax1.YLabel.String = 'Contour (bp)';
ax2.YLabel.String = 'Force (pN)';
ax2.XLabel.String = 'Time (s)';

%Stepfind
if tfstepfind
try
    [in,me,tr] = findStepHistV7d(c, 0.1,[],[],filteropts{3});
catch ME
    %If error is due to array size too large, retry with low memory ver.
    if strcmp(ME.identifier, 'MATLAB:array:SizeLimitExceeded') || strcmp(ME.identifier, 'MATLAB:pmaxsize')
        [in,me,tr] = findStepHistV7dlomem(c, 0.1,[],[],filteropts{3});
    else
        rethrow(ME)
    end
end
in(1) = [];
in(end) = [];
end

%Plot
plot(ax1, t0,c0,'Color',[.7 .7 .7],'LineWidth',1)
plot(ax1, t,c,'Color',color)
plot(ax1b, t0,c0,'Color',[.7 .7 .7],'LineWidth',1)
plot(ax1b, t,c,'Color',color)
if tfstepfind
plot(ax1b, t, tr, 'Color', 'g','LineWidth',1)
end
dt = zoom(1)/10;
dc = zoom(2)/10;
dtind = floor(twinb(2)/(t(2)-t(1)));
dtind2 = floor(dt/(t(2)-t(1)));

plot(ax2, t, f, 'Color', color)
ylim(ax2, [5 15]);

%Scale factor, multiple of window size
scale = 2;
startT = tic;
if tfstepfind
tobjs = gobjects(1,length(me));
end
for i = 1:len
    %Shift window bounds to simulate motion
    xlim(ax1, t(i) + twin)
    xlim(ax1b, t(i) + twinb)
    xlim(ax2, t(i) + twin)
    ylim(ax1,csm(i) +cwin)
    ylim(ax1b, csm(i)+cwin)
    
    if tfstepfind
        %Draw line, number when step occurs
        step = find(in==(i+dtind), 1);
        if step
            j = step;
            line(ax1b, t(in(j))*[1 1] - [0 dt], me(j+1) * [1 1] - [0 dc], 'Color', [0.5 0 0])
            tobjs(j) = text(ax1b, double(t(in(j))-dt), double(me(j+1))-dc, sprintf('%0.1f',me(j)-me(j+1)));
        end
        
        %Remove number when step crosses over (required because @text draws over the axis)
        step2 = find(in==(i+2*dtind+dtind2), 1);
        if step2
            delete(tobjs(step2))
        end
    end
    
    %Print the figure
    if toprint
        print(fig, sprintf('.\\%s\\%s%0.4d',fileout,fileout,i),'-dpng',sprintf('-r%d',96*scale))
        %For some reason, r0 == r96 (1:1 scale)
    else
        drawnow
        pause(.04)
    end
end
if toprint
    close(fig)
end
fprintf('tra2png finished in %0.2fm\n', toc(startT)/60)
end