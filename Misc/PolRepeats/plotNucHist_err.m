function plotNucHist_err(xs, ys, es, inOpts)

%Display options
opts.disp = [558 631 704]-16; %Location of lines
opts.shift = 558 - 16 - 1; %Shift x-axis
opts.normmeth = 2;

%Pause info
opts.pauloc = 59;
opts.per = 64;
opts.nrep = 8;

if nargin > 3
    opts = handleOpts(opts, inOpts);
end

figure('Name', sprintf('PlotNucHist %s', inputname(1)))
hold on
if iscell(ys)
    cellfun(@errorbar, xs, ys, es)
else
    plot(xs, ys, es)
end
%Add lines for pauses
xs = bsxfun(@plus, (0:opts.nrep-1)*opts.per, opts.pauloc');
xs = xs(:)';
yl = ylim;
for i = 1:length(xs)
    line(xs(i) * [1 1], yl)
end
%Red lines for n+1 and -1, in case base offset is wrong
xs2 = bsxfun(@plus, ([-1 opts.nrep])*opts.per, opts.pauloc');
xs2 = xs2(:)';
for i = 1:length(xs2)
    line(xs2(i) * [1 1], yl, 'Color', 'r')
end

%Green lines for display stuff

xs3 = opts.disp;
for i = 1:length(xs3)
    line(xs3(i) * [1 1], yl, 'Color', 'g')
end

%Labels
xlabel('Position (bp)')
switch opts.normmeth
    case 1
        ylabel('Residence time (relative to median)')
    case 2
        ylabel('Residence time (s/bp)')
end

%Shift
ax = gca;
ch = ax.Children;
for i = 1:length(ch)
    ch(i).XData = ch(i).XData - opts.shift;
end