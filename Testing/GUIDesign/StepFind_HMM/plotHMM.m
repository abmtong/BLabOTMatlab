function out = plotHMM(infilepath, itermax)
%takes in filepath or fcdata struct
if nargout > 0
    out = [];
end

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
    
maxiter = length(fcdata.hmm);
optiter= fcdata.hmmfinished;

figure('Name',sprintf('HMM Results %s', f))

ax = subplot(3,1,[1 2]);
plot(prepTrHMM(fcdata.con, .1),'Color', [.7 .7 .7])
ax.YDir = 'reverse';
if nargin < 2
    itermax = inf;
    ind = fcdata.hmmfinished;
else
    ind = min(itermax, maxiter);
    itermax = inf;
end
if ind == 0
    ind = min(itermax, length(fcdata.hmm));
end
hold on
plot(fcdata.hmm(ind).fit, 'Color', 'g')
if ~all(diff(fcdata.hmm(ind).fitmle) == 0)
    plot(fcdata.hmm(ind).fitmle, 'Color', 'r')
end

if nargout > 0
    out = diff(fcdata.hmm(ind).fit);
    out = out(out ~= 0);
end

subplot(3,1,3)
hold on
binsz = 0.1;
% alen = length(fcdata.hmm(1).a);
% x = binsz * (1:alen-1);
len = ind;
lw = .5;
for i = 1:len
    tempa= fcdata.hmm(i).a;
    if i == 1
        alen = length(tempa);
        [~,zpos] = max(tempa);
        x = (1:alen) - zpos;
        x = x * binsz;
    end
    tempa(zpos) = 0;
    %plot lines in increasing saturation of green, last line bold
    if i == len
        lw=2;
        sig = fcdata.hmm(i).sig;
    end
    plot(x,tempa, 'Color', [0 1 0] * i/ len, 'LineWidth', lw)
end
xlim(x([1 end]))

yl = ylim;
line(sig * [1 1], yl)


% figure
% plot(fcdata.tim, fcdata.con, 'Color', [.7 .7 .7]);
% hold on
% plot(windowFilter(@mean, fcdata.tim, [], 10), windowFilter(@mean, fcdata.con, [], 10), 'g')

