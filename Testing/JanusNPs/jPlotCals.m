function [lns, axs] = jPlotCals(axs, nn, hue)
%input: array of four axes

[f, p] = uigetfile('cal*.mat', 'Mu', 'on');
if ~p
    return
end
if ~iscell(f)
    f = {f};
end

if nargin < 1 || isempty(axs)
    fg = figure;
    axs(1) = subplot2(fg, [2 2], 1);
    axs(2) = subplot2(fg, [2 2], 2);
    axs(3) = subplot2(fg, [2 2], 3);
    axs(4) = subplot2(fg, [2 2], 4);
    title(axs(1), 'AX')
    title(axs(2), 'AY')
    title(axs(3), 'BX')
    title(axs(4), 'BY')
    axis(axs(1), 'tight')
    axis(axs(2), 'tight')
    axis(axs(3), 'tight')
    axis(axs(4), 'tight')
end

if nargin < 2
    nn = [];
end

if nargin < 3
    hue = .6;
end

arrayfun(@(x)hold(x, 'on'), axs)
arrayfun(@(x)set(x, 'XScale', 'log'), axs)
arrayfun(@(x)set(x, 'YScale', 'log'), axs)

%If nn is nonempty, use f as a base file name and construct the rest
if ~isempty(nn)
    nn = cellfun(@(x) textscan(x, '%d%s'), nn, 'Un', 0);
    ll = cellfun(@(x) x{2}, nn);
    nn = cellfun(@(x) x{1}, nn);
    mon = textscan(f{1}, 'cal%dN%d.mat');
    mon = mon{1};
    f = arrayfun(@(x) sprintf( sprintf('cal%06dN%%02d.mat', mon) , x ), nn, 'Un', 0);
else
    ll = repmat({'ab'}, [1 length(f)]);
end

len = length(f);
lns = gobjects(len, 4);

for i = 1:len
    %Load
    sd = load(fullfile(p, f{i}));
    cal = sd.stepdata.cal;
    %Slightly randomize color
    col = hsv2rgb([mod(hue + rand*.1, 1), 1, .6]); %Dark color
%     col = hsv2rgb([mod(hue + rand*.1, 1), .3, .9]); %Light color
    
    %Plot power spectra
    if any(ll{i} == 'a')
        lns(i,1) = plot(axs(1), cal.AX.Fall, cal.AX.Pall, 'Color', col);
        lns(i,2) = plot(axs(2), cal.AY.Fall, cal.AY.Pall, 'Color', col);
    end
    if any(ll{i} == 'b')
        lns(i,3) = plot(axs(3), cal.AX.Fall, cal.BX.Pall, 'Color', col);
        lns(i,4) = plot(axs(4), cal.AY.Fall, cal.BY.Pall, 'Color', col);
    end
    drawnow
end








