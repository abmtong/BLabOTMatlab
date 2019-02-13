function out = fitNGaussians(inx, inp, guessmean)

%Make row vectors
inx = double(inx(:)');
inp = double(inp(:)');
guessmean = guessmean(:)';

%length(guessmean) is the number of gaussians to fit
if nargin < 3 || isempty(guessmean)
    guessmean = [5 10];
end

n= length(guessmean);

gauss = @(x, xbar,var) exp(-(x-xbar).^2/2/var);
gauss2 = @(op, x) op(1) * gauss(x, op(2), op(3));

%       [amp mean sd; ''; '';]
%       Guess [.1, mean, 1]
Guess = [.1*ones(n,1), guessmean', 1*ones(n,1)];
lb = zeros(n,3);
ub = repmat([1 20 20],n, 1);

    function outY = ngauss(xG, opG)
        nG = size(opG,1);
        outY = zeros(1,length(xG));
        for iG = 1:nG
            outY = outY + gauss2(opG(iG,:), xG);
        end
    end

fitfcn = @(op, x) ngauss(x, op);

out = lsqcurvefit(fitfcn, Guess, inx, inp, lb, ub);

figure('Name',sprintf('%d Gaussians', n))
bar(inx, inp, 'FaceColor', [.8 .8 .8])
hold on
str = [];
%Create a string displaying amplitude, mean, sd of each gaussian
for i = 1:n
    plot(inx, gauss2(out(i,:),inx))
    str = [str sprintf('Amp: %0.2f, Mean:%0.2f, SD:%0.1f\n', out(i,:))]; %#ok<AGROW>
end
y = fitfcn(out, inx);

%Place the text at (where curve hits half maxY, maxY)
[texty, ind] = max(y);
textxind = find(inx > inx(ind) & y < texty/2,1,'first');
plot(inx, y, 'Color','k')

text(inx(textxind), texty, str)
end