function plotTracesV2(inOpts)

%Default options
opts.path = [];
opts.nameTraces = 1;
opts.normCon = 0;
opts.dT = 3;
opts.fwid = [];
opts.fdec = 10;
opts.name = '';
opts.ax = [];
opts.cropstr = '';
opts.ymult = 1;
opts.Fs = 2500;
opts.plotUnfilt = 0;

if nargin
    opts = handleOpts(opts, inOpts);
end

%Get filepath if not specified
if isempty(opts.path)
    opts.path = uigetdir('D:\Data\');
    if ~opts.path
        return
    end
end

%Make figure + axes, or use passed axes
if isempty(opts.ax)
    fg = figure('Name', sprintf('PlotTraces %s', opts.name), 'Color', ones(1,3));
    opts.ax = axes(fg);
end
ax = opts.ax;
hold(ax, 'on')

%Get traces with getFCs
[dat, ~, ~, datn, datnam] = getFCs(opts.cropstr, opts.path);
datF = cellfun(@(x) windowFilter(@mean, x, opts.fwid, opts.fdec), dat, 'Un', 0);

%Make time coords
ts = arrayfun(@(x) (1:x) / opts.Fs, cellfun(@length, dat), 'Un', 0);
tf = cellfun(@(x) x(end), ts);
for i = 2:length(tf)
    %If the same file, increment time
    if datn(i) == datn(i-1)
        ts{i} = ts{i} + ts{i-1}(end);
    end
end

tF = cellfun(@(x) windowFilter(@mean, x, opts.fwid, opts.fdec), ts, 'Un', 0);

%Get color, to plot traces the same color (key off of trN field)
cols = mat2cell( lines(7), ones(1,7) );
nc = length(cols);

%And con offsets
if opts.normCon
    y0s = cellfun(@(x) x(1), datF);
    [~, ic, ia] = unique(datn);
    y0s = y0s(ic(ia));
    dys = 30 * datn; %Technically a bit wrong, should be 30 * trace num which isnt trN
    yoff= arrayfun(@(x,y) 9000 - x - y  , y0s, dys);
else
    yoff = zeros(1,length(dat));
end

%Plot unfiltered
if opts.plotUnfilt
    cellfun(@(x,y,z)plot(ax, x,y+z,'Color', .7 * ones(1,3)), ts, dat, num2cell(yoff));
end
%Plot filtered
cellfun(@(x,y,z,ci)plot(ax, x,y+z, 'Color', cols{ mod(ci-1,nc)+1 }, 'LineWidth', 1), tF, datF, num2cell(yoff), num2cell(datn) );

%Add names to the end of each 
if opts.nameTraces
    %Strip the .mat
    datnam = cellfun(@(x) x(1:end-4), datnam, 'Un', 0);
    
    %Get the last FC of each unique trace
    [~, ci, ~] = unique( fliplr(datn) );
    ci = length(datn) + 1 - ci;
    yn = cellfun(@(x) x(end), datF(ci));
    tn = cellfun(@(x) x(end), tF(ci));
    cellfun(@(x,y,z)text(ax,x,y,z, 'Interpreter', 'none'), num2cell(tn), num2cell(double(yn+yoff(ci))), datnam(ci))
end

%Set up axis
xlabel(ax, 'Time (s)')
ylabel(ax, 'Position (bp)')
ax.FontSize = 16;





