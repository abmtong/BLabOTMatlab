function setCondColors(ax)

if nargin < 1
    ax = gca;
end

if nargin < 2
    rep = 1;
end

%Five colors 
ncol = 5;
cols = arrayfun(@(x) hsv2rgb(x, 1, .7), (0:ncol-1)/ncol, 'Un', 0);

ch = ax.Children;
len = length(ch);

for i = 1:len
    ch(end-i+1).Color = cols{mod( i-1, ncol) + 1 };
end

