function [out, y] = kdftri(indata, dy, ysd)
%kdf with a triangle of width 2*ysd instead of a gaussian

if nargin < 3
    ysd = 1;
end
if nargin < 2
    dy = 0.1;
end

%outputs a triangle wave centered at mu, width sigma
%hence area = 1 = sigma * h, h = 1/sigma
    function outp = tri(inx, mu, sig)
        %draw increasing/decreasing lines
        %slope = height / sigma = 1/sig^2
        %y-y0 = m(x-x0), our pt is (mu, 1/sigma)
        m = 1/sig^2;
        outp = m*(inx - mu) + 1/sig;
        sec2 = inx(inx >= mu);
        outp(inx>=mu) = -m*(sec2 - mu) + 1/sig;
        %zero negative values
        outp(outp<0) = 0;
    end
% len = length(indata);

miny = floor( min(indata)/dy ) * dy;
maxy = ceil( max(indata)/dy) * dy;

y = miny:dy:maxy;

out = zeros(1,length(y));

for i = indata
    out = out + tri(y, i, ysd);
end

end
