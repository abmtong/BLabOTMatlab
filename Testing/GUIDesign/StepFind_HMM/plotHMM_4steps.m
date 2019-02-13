function plotHMM_4steps(infilepath, itermax)
%takes in filepath or fcdata struct

if nargin<1 || isempty(infilepath)
%     [f, p] = uigetfile('C:\Data\pHMM*.mat');
    [f, p] = uigetfile('E:\dsRNA - HMM\HMM');
    infilepath = [p filesep f];
else
    f = '';
end

if isstruct(infilepath)
    fcdata = infilepath;
else
    fcdata = load(infilepath, 'fcdata');
    fcdata = fcdata.fcdata;
    [~,f] = fileparts(infilepath);
end

if ~isfield(fcdata, 'hmm') || isempty(fcdata.hmm)
    fprintf('No HMM data.\n')
    return
end
    

figure('Name',sprintf('HMM Results %s', f))

ax = subplot(3,1,[1 2]);
plot(prepTrHMM(fcdata.con, .1),'Color', [.7 .7 .7])
ax.YDir = 'reverse';
if nargin < 2
    itermax = inf;
    ind = fcdata.hmmfinished;
else
    ind = min(itermax, fcdata.hmmfinished);
    itermax = inf;
end
if ind == 0
    ind = min(itermax, length(fcdata.hmm));
end
hold on
% plot(fcdata.hmm(ind).fit, 'Color', 'g')
len = length(fcdata.con);
if ~all(diff(fcdata.hmm(ind).fitmle) == 0)
    
    mesh(repmat(1:len, [2 1]), repmat(real(fcdata.hmm(ind).fitmle+1), [2 1]), zeros(2,len), repmat(imag(fcdata.hmm(ind).fitmle), [2 1]) )
    mesh(repmat(1:len, [2 1]), repmat(real(fcdata.hmm(ind).fit), [2 1]), zeros(2,len), repmat(imag(fcdata.hmm(ind).fit), [2 1]) )
    colorbar, colormap jet

%     plot(fcdata.hmm(ind).fitmle, 'Color', 'r')
end

subplot(3,1,3)
hold on
binsz = 0.1;
x = binsz:binsz:25;
len = ind;
% lw = .5;
dind = ceil(len/10);
for i = len:-dind:1
    tempa= fcdata.hmm(i);
    %plot lines in increasing saturation of green, last line bold
    if i == len
        lw=2;
    else
        lw = .5;
    end
    plot(x,tempa.a.ds1, 'Color', [0 1 0] * i/ len, 'LineWidth', lw)
    plot(x,tempa.a.ds2, 'Color', [0 0 1] * i/ len, 'LineWidth', lw)
end
xlim([0,10])
yl = ylim;

line(tempa.sig * [1 1], yl)


% figure
% plot(fcdata.tim, fcdata.con, 'Color', [.7 .7 .7]);
% hold on
% plot(windowFilter(@mean, fcdata.tim, [], 10), windowFilter(@mean, fcdata.con, [], 10), 'g')

