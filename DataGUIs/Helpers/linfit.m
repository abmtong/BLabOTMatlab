function [outM, outB] = linfit(x,y)
if nargin<2
    y = x;
    x = (1:numel(y));
end
xmax = max(x);
x = x/xmax; %Small x makes @mldivide more well-behaved
v = [x(:) ones(numel(x),1)];
outP = v\y(:);
outM = outP(1)/xmax;
outB = outP(2);