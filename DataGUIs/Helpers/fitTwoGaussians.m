function out = fitTwoGaussians(inx, inp, guessmean)

if nargin < 3 || isempty(guessmean)
    guessmean = [5 10];
end

gauss = @(x, xbar,var) exp(-(x-xbar).^2/2/var);
gauss2 = @(op, x) op(1) * gauss(x, op(2), op(3));
fitfcn = @(op, x) ( gauss2(op(1:3), x) + gauss2(op(4:6), x) );

%       [amp mean sd '']
Guess = [.1 guessmean(1) 1 .05 guessmean(2) 1];
lb = [0 0 0 0 0 0];
ub = [1 20 20  1 20 20];

out = lsqcurvefit(fitfcn, Guess, inx, inp, lb, ub);

figure('Name','Two Gaussians')
bar(inx, inp, 'FaceColor', [.8 .8 .8])
hold on
g1 = gauss2(out(1:3), inx);
g2 = gauss2(out(4:6), inx);

plot(inx, g1, 'Color', 'r')
plot(inx, g2, 'Color', 'b')
plot(inx, g1+g2, 'Color','k')

text(5, 0.3, sprintf('Mean:%0.2f SD: %0.2f\nMean:%0.2f SD: %0.2f', out(2), out(3), out(5), out(6)))