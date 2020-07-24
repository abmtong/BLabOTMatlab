function outrgb = colorcircle(n, V)
%Creates n colors in a rainbow with Value V (HSV colorspace)
%Does this by creating n equally-spaced hues (HSV colorspace), then normalizing their lightness (LAB colorspace)
% Normalizing step done since colors at the same Value have different Lightnesses
% Set V instead of L since it seems to work more consistently that way. YMMV
%i.e. convert (h, 1, V) colors to (L, A, B), normalize L's, then convert to RGB
%Can alternatively pass n=[n1,n2] which returns the n1-th color of outrgb(n2, V)

if nargin < 2
    V = .7;
end

%Check what n was passed
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