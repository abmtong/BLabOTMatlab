function fitSkewGauss(guessmean)
if nargin < 1
    guessmean = [2.5 5];
end
ax = gca;
x = ax.Children.XData;
p = ax.Children.YData;

%Make row vectors
x = double(x(:)');
p = double(p(:)');
guessmean = guessmean(:)';

%length(guessmean) is the number of gaussians to fit
if ~nargin || isempty(guessmean)
    guessmean = [5 10];
end

n= length(guessmean);

skgauss = @(op, x) op(1) * sqrt(pi/2) * op(3) *2 * normpdf(x, op(2), op(3)) .* normcdf(x*op(4), op(2), op(3));% * 2*pi*op(3)^2;

%       [amp mean sd skew; ''; '';]
%       Guess [.1, mean, 1, 0]
%Guess each is a gaussian with height .1, mean given, sd 1, skewness 1/2
Guess = [.1*ones(n,1), guessmean', 1*ones(n,1), ones(n,1)/2];
lb = repmat([0  0  0 -20], n, 1);
ub = repmat([1 20 20 20],n, 1);

    function outY = nskgauss(xG, opG)
        nG = size(opG,1);
        outY = zeros(1,length(xG));
        for iG = 1:nG
            outY = outY + skgauss(opG(iG,:), xG);
        end
    end

fitfcn = @(op, x) nskgauss(x, op);

out = lsqcurvefit(fitfcn, Guess, x, p, lb, ub);

figure('Name',sprintf('%d Gaussians', n))
bar(x, p, 'FaceColor', [.8 .8 .8])
hold on
str = [];
%Create a string displaying amplitude, mean, sd of each gaussian
for i = 1:n
    plot(x, skgauss(out(i,:),x))
    str = [str sprintf('Amp: %0.2f, Mean:%0.2f, SD:%0.1f, Skew:%0.2f\n', out(i,:))]; %#ok<AGROW>
end
y = fitfcn(out, x);

%Place the text at (where curve hits half maxY, maxY)
[texty, ind] = max(y);
textxind = find(x > x(ind) & y < texty/2,1,'first');
plot(x, y, 'Color','k')

text(x(textxind), texty, str)
end