function sgdiftest()

N = 4;                 % Order of polynomial fit
F = 21;                % Window length
[b,g] = sgolay(N,F);   % Calculate S-G coefficients

dx = 0.2;
xLim = 200;
x = 0:dx:xLim-1;

y = 5*sin(0.4*pi*x) + 3*randn(size(x));  % Sinusoid with noise

HalfWin  = ((F+1)/2) -1;

for n = (F+1)/2:996-(F+1)/2,
  % Zeroth derivative (smoothing only)
  SG0(n) = dot(g(:,1),y(n - HalfWin:n + HalfWin));

  % 1st differential
  SG1(n) = dot(g(:,2),y(n - HalfWin:n + HalfWin));

  % 2nd differential
  SG2(n) = 2*dot(g(:,3)',y(n - HalfWin:n + HalfWin))';
end

sgc1 = conv(y, flipud(g(:,2)), 'same');

sgc2 = xcorr(y, g(:,2));
sgc2 = sgc2(length(y)-HalfWin:end-HalfWin);

figure, hold on, %plot(smooth(diff(y),F), 'Color', [.7 .7 .7]), 
plot(SG1+.1), plot(sgc1+.2), plot(sgc2+.3), 
plot([zeros(1,HalfWin) sgolaydiff(y, {N F})]+.4)
