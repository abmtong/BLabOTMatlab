function [out, y] = kdf(indata, dy, ysd)

if nargin < 3
    ysd = 1;
end
if nargin < 2
    dy = 0.1;
end

% len = length(indata);

miny = floor( min(indata)/dy ) * dy;
maxy = ceil( max(indata)/dy) * dy;

y = miny:dy:maxy;

out = zeros(1,length(y));

for i = indata
    out = out + normpdf(y, i, ysd);
end

