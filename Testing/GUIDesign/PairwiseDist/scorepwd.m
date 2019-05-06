function out = scorepwd(inp, binsz, range)
if nargin < 3
    range = [2.3 2.7];
end

if nargin < 2
    binsz = 0.1;
end
inp = inp(:)';
xl = 1e3;

x = zeros(1,xl);
len = length(inp);
x(1:len) = inp;


pf = abs(fft(x));
xf = xl./(0:xl-1) * binsz;

pf = pf(2:end)/pf(1);
xf = xf(2:end);

% figure, plot(xf, pf), xlim([0 10])
out = sum( pf( xf > range(1) & xf < range(2) ) );