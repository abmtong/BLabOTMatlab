function lofqnoi = simnoisesin(n)
if nargin < 1
n = 1e3;
end
lofqnoi = zeros(1,n);
curang = 0;
avgfrq = 50;%avg period (pts)
for i = 1:n
    lofqnoi(i) = sin( 2*pi*curang );
    randnum = randi(100) / (101/2) / avgfrq;
    curang = curang + randnum; %random increment to curang, so noise isn't exactly sinusoidal
end