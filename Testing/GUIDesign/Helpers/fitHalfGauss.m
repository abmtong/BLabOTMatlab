function fitHalfGauss(guessmean)
%Fits two gaussians per guessmean, with means guessmean and guessmean/2

%length(guessmean) is the number of gaussians to fit
if ~nargin || isempty(guessmean)
    guessmean = [10];
end

ax = gca;
x = ax.Children.XData;
p = ax.Children.YData;

%Make row vectors
x = double(x(:)');
p = double(p(:)');
guessmean = guessmean(:)';



n= length(guessmean);

halgauss = @(op, x) op(1) * normpdf(x, op(2), op(3)) + op(4) * normpdf(x, op(2)/2, op(5));

%       [amp1 mean sd1 amp2 sd2; ''; '';]
%       Guess [.1, mean, 1, .1, 1]
%Guess each is a gaussian with height .1, mean given, sd 1, skewness 1/2
Guess = [.1*ones(n,1), guessmean', 1*ones(n,1), .1*ones(n,1), 1*ones(n,1)];
lb = repmat([0  0  0 0 0], n, 1);
ub = repmat([1 20 20 20 20],n, 1);

    function outY = nhalgauss(xG, opG)
        nG = size(opG,1);
        outY = zeros(1,length(xG));
        for iG = 1:nG
            outY = outY + halgauss(opG(iG,:), xG);
        end
    end

fitfcn = @(op, x) nhalgauss(x, op);

out = lsqcurvefit(fitfcn, Guess, x, p, lb, ub);

figure('Name',sprintf('%d Gaussians', n))
bar(x, p, 'FaceColor', [.8 .8 .8])
hold on
str = [];
%Create a string displaying amplitude, mean, sd of each gaussian
for i = 1:n
    plot(x, halgauss(out(i,:),x))
    str = [str sprintf('Amp: %0.2f, Mean:%0.2f, SD:%0.1f\n  Amp: %0.2f, Mean:half, SD:%0.1f\n', out(i,:))]; %#ok<AGROW>
end
y = fitfcn(out, x);

%Place the text at (where curve hits half maxY, maxY)
[texty, ind] = max(y);
textxind = find(x > x(ind) & y < texty/2,1,'first');
plot(x, y, 'Color','k')

text(x(textxind), texty, str)
end