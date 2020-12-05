function plotJNP(infp)

if nargin < 1
    [f, p] = uigetfile('*.mat', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        cellfun(@(x) plotJNP(fullfile(p,x)),f)
        return
    end
    infp = fullfile(p,f);
end

%Load file
dat = load(infp);
dat = dat.ContourData;

%Set up figure
[~,f,~] = fileparts(dat.name);
figure('Name', sprintf('%s: %s', f, dat.comment));

%Plot Force-Time (X), Force-Time (Y), GPSD-Time
ax1 = subplot2([3 1], 1);
plot(ax1, dat.time, dat.forceBX, 'Color', [.7 .7 .7]);
hold(ax1, 'on');
plot(ax1, windowFilter(@mean, dat.time, [], 100), windowFilter(@mean, dat.forceBX, [], 100), 'Color', 'b');
xlabel(ax1, 'Time(s)')
ylabel(ax1, 'Force BX (pN)')

ax2 = subplot2([3 1], 2);
plot(ax2, dat.time, dat.forceBY, 'Color', [.7 .7 .7]);
hold(ax2, 'on');
plot(ax2, windowFilter(@mean, dat.time, [], 100), windowFilter(@mean, dat.forceBY, [], 100), 'Color', 'r');
xlabel(ax2, 'Time(s)')
ylabel(ax2, 'Force BY (pN)')

ax3 = subplot2([3 1], 3);
plot(ax3, dat.Grn.GrnTime, dat.Grn.GrnOn .* dat.Grn.GrnPDSum, 'Color', 'g');
hold(ax3, 'on')
xlabel(ax3, 'Time(s)')
ylabel(ax3, 'Green Power (arb.)')
plot(ax3, [min(dat.Grn.GrnTime) max(dat.Grn.GrnTime)], dat.Grn.GrnPDSum(1) * [1 1], 'Color', 'k');

linkaxes([ax1 ax2 ax3], 'x')

