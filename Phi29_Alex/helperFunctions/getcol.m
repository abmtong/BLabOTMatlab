function outcol = getcol(i, n, opt)
%returns a sequence of rainbow colors, generated using @hsv2rgb.
%i,n determine the hue output, where hue = (i-1)/n + .9, i.e. if i = 1, the color is red, then cycles through the rainbow (in ROYGBIV order) until i=n+1 where it is red again
%opt determines whether the color is saturated (1) or grayed/pastel (0). They correspond to a preset [s,v] combination.
%usage: usually for plotting traces with an ordered color sequence (instead of matlab's default color order, which is not obviously sequential)
%     e.g. cellfun(@(x, y, col) plot(x, y, 'Color', col), xcell, ycell, getcol(1:length(xcell), 10, 1));

if nargin < 3
    opt = 1; %saturated colors
end
if nargin < 2
    n = max(i);
end

%gets rainbow colors defined by these [h, s, v], where h = h0 + i/n
h0 = .9;%first color red
if opt
    s = 1;
    v = .6;
else
    s = .3;
    v = .8;
end

len = length(i);
outcol = arrayfun( @(x) hsv2rgb([x, s, v]), mod( (i-1)/n + h0, 1), 'Uni', 0);

if len == 1;
    outcol = outcol{1};
end


