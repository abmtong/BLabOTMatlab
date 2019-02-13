function tra2png(filein, fileout, outsize, zoom, timeInds, fps, filteropts)

% filein: phage*.mat to open
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
    zoom = [2, 400];
end
if nargin<5 || isempty(timeInds)
    timeInds = [0 inf];
end
if nargin<6 || isempty(fps)
    fps = 60;
end
if nargin<7 || isempty(filteropts)
    filteropts = {@mean, [], 10};
end

%Set up figure
fig = figure('Name','PrintWindow');
fig.Position = [0 0 outsize];
hold on;
ax = gca;

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
t = t(ikeep);
x = x(ikeep);
f = f(ikeep);

%Filter
t = windowFilter(filteropts{1},t,filteropts{2:end});
f = windowFilter(filteropts{1},f,filteropts{2:end});
c = windowFilter(filteropts{1},c,filteropts{2:end});
len = length(t);

%dT for trace, should be 4ms for 250kHz
dTtr = t(2)-t(1);
%dT for fps, s
dTmov = 1/fps;
%Take every Nth frame. For default 250Hz > 60fps, 5
ptN = max(round(dTmov/dTtr),1);

%Make output folder
if ~exist(fileout, 'dir')
    mkdir(fileout)
end

%Might want to work with non-feedback cycle'd data
color = 'k';
twin = [-zoom(1) 0];
cwin = [0 zoom(2)] - zoom(2)/10;
tmin = 0;
tmax = t(end);
ttick = 0.2;
xt = tmin:ttick:tmax+ttick;
ax.XTick = xt;
ax.XTickLabel = arrayfun(@(x)num2str(x,'%0.1f'), xt, 'UniformOutput', false);
for i = 1:floor(len/ptN)-1
    %Find next points
    N = (i-1)*ptN+1; %Looking for points from N to N+ptN, need overlap so separate lines overlap
    ran = N:N+ptN;
    
    %Plot next points
    plot(t(ran),c(ran),'Color',color)
    %determine next window bounds
    xlim(ax, dTtr*(N+ptN) + twin)
    ylim(ax,mean(c(ran)) +cwin) %smooth y-jitter by taking avg. of pts for now
    
    %Print the figure
    print(fig, sprintf('.\\%s\\%s%0.4d',fileout,fileout,i),'-dpng','-r0')
end
close(fig)
%TO ADD
%{
Stabilization to y window- should probably set scrolling with smooth(ptN) or something like that
%}
end