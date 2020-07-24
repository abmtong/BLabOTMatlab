function velvpos(inx, sgf)
%Maybe we can see the 40deg transition by this plot?
% Answer: no

if nargin < 2
    sgf = {1 21}; %sgf params
end

%Filter inx, get slope
[vf, xf, xc] = sgolaydiff(inx, sgf);

%Turn x to x mod 1/3
xf = mod(xf,1/3);

%Make histogram
[nn, xx, yy] = histcounts2(xf, vf);

%Convert bin edges to bin centers
xx = (xx(1:end-1) + xx(2:end))/2;
yy = (yy(1:end-1) + yy(2:end))/2;

figure, surf(xx, yy, nn')
colorbar
% set(gca, 'clim', [0 100])
% zlim([0 100])