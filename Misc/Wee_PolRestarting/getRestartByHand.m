function out = getRestartByHand(infp)
%Lets user click start and end to get timescales
% Made for pol restarting (start of flow to start of Tx)

if nargin < 1
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    infp = cellfun(@(x) fullfile(p, x), f, 'Un', 0);
end

len = length(infp);

yla = [2900 3100];
ywid = 200;

npts = 2; %Points to click per graph

sm = 10;%Smoothing factor

%Preallocate output
gout = zeros(npts,len);
islong = zeros(npts,len);
frc = zeros(1,len);

ssz = get(groot, 'ScreenSize');
fg = figure('Position', ssz + [ssz(3:4)/10 -ssz(3:4)/5]);
ax1 = subplot2(fg, [3 1], [1 2]);
ax2 = subplot2(fg, [3 1], 3);
linkaxes([ax1, ax2], 'x')
hold(ax2,'on');

for i = 1:len
    %Load
    sd = load(infp{i});
    sd = sd.stepdata;
    f = smooth([sd.force{:}], sm)';
    c = smooth([sd.contour{:}],sm)';
    fax = smooth([sd.forceAX{:}],sm)';
    fbx = smooth(-[sd.forceBX{:}],sm)';
    %Plot the trace above, force X below
    cla(ax1)
    cla(ax2)
    plot(ax1, c);
    drawnow
    yl=ylim(ax1);
    ylim(ax1, yl(1) + [0 ywid])
    plot(ax2, fax);
    plot(ax2, fbx);
    wid = length(c);
    xlim([0 wid*1.1])
    fn = fileparts(infp{i});
    text(ax1, 1, mean(yla), sprintf('%d, %s', i, fn));
    
    [a, ~] = ginput(2);
    a=round(a);
    %Choose reverse to ignore (i.e. ambiguous)
    if ~issorted(a)
        islong(:,i) = [0 0];
        gout(:,i) = [0 0];
        frc(i) = 0;
        continue
    end
    in = a>wid; %If a point is chosen after the end, acknowledge
    a(in) = wid;
    frc(i) = mean( f(a(1):a(end)) );
    
    gout(:,i) = a;
    islong(:,i) = in;
end

%Out is a struct with fields indicies (chosen pts), fp (same as in), force
goutcell = mat2cell(gout', ones(1,len))';
ioutcell = mat2cell(islong', ones(1,len))';
out = struct('ind', goutcell, 'long', ioutcell, 'frc', num2cell(frc), 'fp', infp);