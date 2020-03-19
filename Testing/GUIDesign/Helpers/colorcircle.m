function outrgb = colorcircle(n, V)
%Creates n equally-spaced (in hue, HSV) colors with the same L (in lightness, LAB)
%i.e. convert (h, 1, V) colors to (l, a, b), equalize L, then convert back to RGB

%@inputs
%n is either a scalar (then number of colors) or a 1x2 vector, which returns the ith color of n

if nargin < 2
    V = .7;
end

%check what n was passed
if numel(n) == 2
   ni = n(1);
   n = n(2);
else
    ni = 1:n-1;
end

%Create hues
h = linspace(0,1,n+1);
h = h(ni);
collab = arrayfun(@(x) rgb2lab(hsv2rgb(x, 1, V) ), h, 'Un', 0);
%Calculate mean L
Lbar = mean( cellfun(@(x) x(1), collab) );
outrgb = cellfun(@(x) lab2rgb([Lbar x(2) x(3)]), collab, 'Un', 0);

%LAB can give negative RGB values, so.. shift and scale?
rn = [outrgb{:}];
rmin = min(rn);

if rmin >=0 %only shift if we have to
    rmin = 0;
    rrng = max(rn);
else
    rrng = range(rn);
end
rrng = max(rrng,1);%Only scale if we have to

outrgb = cellfun(@(x) (x - rmin)/rrng , outrgb, 'Un', 0);

%if one output, un-cell
if length(outrgb) == 1
    outrgb = outrgb{1};
end

%{
V1: set L, instead of setting V

function outrgb = colorcircle(n, L)
%Creates equally-spaced (in hue, HSV) colors with the same L (in lightness, LAB)
%i.e. convert (h, 1, 1) colors to (l, a, b) and then set L to be the same, then convert back to RGB

if nargin < 2
    L =70; %L is in [0, 100]. Since we have to scale later, doesn't always scale with lightness...
    %Try using ~1 for dark colors, ~60 for light colors
end

h = linspace(0,1,n+1);
h = h (1:end-1);
collab = arrayfun(@(x) rgb2lab(hsv2rgb(x, 1, 1) ), h, 'Un', 0);
outrgb = cellfun(@(x) lab2rgb([L x(2) x(3)]), collab, 'Un', 0);

%LAB can give negative RGB values, so.. shift and scale?
rn = [outrgb{:}];
rmin = min(rn);

if rmin >=0 %only shift if we have to
    rmin = 0;
    rrng = max(rn);
else
    rrng = range(rn);
end
rrng = max(rrng,1);%Only scale if we have to

outrgb = cellfun(@(x) (x - rmin)/rrng , outrgb, 'Un', 0);
%}