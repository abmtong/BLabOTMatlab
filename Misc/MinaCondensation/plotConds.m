function axs= plotConds(trcs)

%Input: Cell of traces, [here] order -ATP +ATP -ASF1 -Cond

%Plot as vertical subplots, axis hold

nn = length(trcs);
plch = @(x, hue) plot((1:length(x)) / 1e3, windowFilter(@mean, x, 10, 1) - mean(x(end-10:end)), 'Color', hsv2rgb( mod(hue + (rand-0.5)/10, 1) , 1, .7));

tits = {'-ATP' '+ATP' '-ASF1' '-Cond'};
figure('Color', [1 1 1])
for i = nn:-1:1
    axs(i) = subplot2([1,nn], i);
    hold on
    cellfun(@(x)plch(x,(i-1)/nn), trcs{i})
    title(tits{i})
end
linkaxes(axs, 'xy')
ylabel(axs(1), 'Extension (nm, rel.)')
arrayfun(@(x)xlabel(x, 'Time(s)'), axs)
arrayfun(@(x) set(x, 'FontSize', 14), axs)
