function fg = findEinstein_Plot(inst, dy, inds)

%If traces not chosen, just pick the best 5
if nargin < 3
    [~, si] = sort([inst.sc]);
    inds = si(1:5);
end

%Guess dy from the traces
if nargin < 2 || isempty(dy)
    [~, dy] = tra2ind(inst(1).ft);
    dy = median(diff(dy));
end

filwid = 10;
Fs = 2500;

fg = figure('Name', sprintf('PlotEinstein: %s, inds %s', inputname(1), num2str(inds)));
ax = axes(fg);
hold(ax, 'on')

toff = 0;
t = (1:length(inst(end).tr)) / Fs;

%Reorder by slope, so we put faster > slow
ms = cellfun(@(x) polyfit(t, x, 1), {inst(inds).tr}, 'Un', 0);
ms = reshape([ms{:}], 2, []);
ms = ms(1,:);
[~, sm] = sort(abs(ms), 'descend');
inds = inds(sm);

%For every trace...
for i = inds;
    seg = inst(i);
    %Get the y offset, by setting the line before the first dy transition to y=0
    [in, me] = tra2ind(seg.ft);
    yoff = me(find(diff(me) == dy, 1, 'first'));
    %Plot
    y = inst(i).tr  - yoff;
    plot(ax, t + toff, y, 'Color', [.7 .7 .7]);
    plot(ax, t + toff, windowFilter(@mean, y, filwid, 1));
    %Calculate required t offset
    toff = toff + (in(2)-in(1))/Fs + t(end)/10;
end

%Add dotted lines; add as one curve for easy changing

%Get curve limits so we know where to start/stop
yl = ylim;
xl = xlim;

%Form y-matrix; similar to how it's done in @findEinstein
maxy = abs(dy(end));
yimax =  ceil(yl(2) / maxy)+2;
yimin = floor(yl(1) / maxy)-2;
%Make even (make their difference odd), makes lining up with xl easier
yimin = yimin - mod(yimax-yimin + 1, 2);
yi = yimin:yimax;
if dy(end) < 0
    yi = fliplr(yi);
end
ys = bsxfun(@plus, dy', yi*maxy);
ys = ys(:)';

%Duplicate every value
ys = repmat(ys, 2, 1);
ys = ys(:)';

%Extend xl a bit each way
xle = xl + [-1 1]* range(xl)/2;

%X values repeat x([1 2 2 1 ...])
xs = repmat( [xle fliplr(xle)], 1, length(ys)/4 );

%Plot the square wave
plot(ax, xs, ys, 'k:', 'LineWidth', 2)
xlim(xl);
ylim(yl);
