function out = colorscale(indata, minval, maxval)
%scales (e.g. a surface's) color data to be within min and max
if nargin < 2
    minval = 0;
end
if nargin < 3
    maxval = 1;
end

dmax = max(indata(:));
dmin = min(indata(:));

out = (indata - dmin) * (maxval-minval) / (dmax - dmin) + minval;