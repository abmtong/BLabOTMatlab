function outcol = getcol(i,n,s)

if nargin < 3
    s = 1; %Color saturation; 1 for bold colors, .25 for pastel-y colors
end

if nargin < 2
    n = 10;
end

if nargin < 1
    i = 1;
end

if length(i) > 1
    outcol = arrayfun(@(x)getcol(x,n,s), i , 'Un', 0);
    return
end

dcol = 1/n;
col0 = 2/3; %blue
h = mod(col0 + (i-1)*dcol,1); %Color wheel, blue > red > grn
v = .6; % too high makes yellow difficult to see, too low and everything is muddy
outcol = hsv2rgb( h, s, v);