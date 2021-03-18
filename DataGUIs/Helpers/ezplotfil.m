function out = ezplotfil(inx, iny, wid)
%Plots a trace and its filtered coords

%Accept inputs as @(iny), @(iny, wid), @(inx, iny), @(Fs, iny), @(inx, iny, wid)
if nargin == 1
    iny = inx;
    inx = 1:length(iny);
    wid = [];
end

if nargin == 2
    if length(iny)==1
        wid = iny;
        iny = inx;
        inx = 1:length(iny);
    elseif length(inx) == 1 
        inx = (1:length(iny))/inx;
        wid = [];
    else
        wid = [];
    end
end

if isempty(wid)
    wid = 20;
end

ax=gca;
ho = ishold(ax);
hold(ax, 'on')
ci = get(ax, 'ColorOrderIndex');
o1 = plot(ax, inx, iny, 'Color', [.7 .7 .7]);
set(ax, 'ColorOrderIndex', ci)
o2 = plot(smooth(inx, wid), smooth(iny, wid));
if ho
    hold(ax, 'on')
else
    hold(ax, 'off')
end

if nargout > 0
    out = [o1 o2];
end