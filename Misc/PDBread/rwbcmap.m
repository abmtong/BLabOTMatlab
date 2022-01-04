function out = rwbcmap(n, inv)

if nargin < 1
    n = 64; %Number of levels of the colormap
end

if nargin < 2
    inv = 0; %Invert red and blue scale
end

%Red-white-blue colormap

%Fade first half red > white, then second half white > blue?

%Do fade by decreasing saturation
h = round(n/2);
s = (1:h)'/h;
o = ones(h,1);

outhsv = [ o flipud(s) o ; o*2/3 s o]; %[ Red Sat-fade MaxValue ; Blue Sat-increase MaxValue]

if inv
    outhsv = flipud(outhsv);
end

out = hsv2rgb(outhsv);