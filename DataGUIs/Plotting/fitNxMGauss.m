function fitNxMGauss(guessmean, relmean, xl)
%Fits gaussians with mean guessmean x relmeans

%length(guessmean) is the number of gaussians to fit
if ~nargin || isempty(guessmean)
    guessmean = 10;
end
if nargin<2  || isempty(relmean)
    relmean = 1;
end
if nargin < 3 || isempty(xl)
    xl = [0 inf];
end

ax = gca;
x = ax.Children(end).XData;
p = ax.Children(end).YData;
keepind = x>xl(1) & x < xl(2);
x = x(keepind);
p = p(keepind);

%Make row vectors
x = double(x(:)');
p = double(p(:)');

%check if it's from @bar (is a patch, and is plotted differently)
if isa(ax.Children(end), 'patch')
[x, ix] = unique(x);
p = p(ix);
end
%renormalize
p = p / sum(p) * mean(abs(diff(x)));

guessmean = guessmean(:)';

gauss = @(op, x) op(1) * exp(-((x-op(2))/op(3)).^2/2);

n= length(guessmean);
m = length(relmean);

%       [mean1 amp1a sd1a amp1b sd1b ...; ''; '';]
%       Guess [.1, mean, 1, .1, 1]
%Guess each is a gaussian with height median(y), mean given, sd range(x)/10
mdht = max(p);
xrng = range(x);

Guess = [guessmean' repmat([mdht xrng/100],n,m)];
lb = [(min(x)-range(x))*ones(n,1) repmat([0 0],n,m)];
ub = [(max(x)+range(x))*ones(n,1) repmat([mdht*1e3 xrng*20],n,m)];

    function outY = nmgauss(xG, opG)
        [nG, mG] = size(opG);
        mG = (mG-1)/2;
        outY = zeros(1,length(xG));
        for iG = 1:nG
            for jG = 1:mG
                outY = outY + gauss([opG(iG,jG*2), opG(iG,1)*relmean(jG), opG(iG,jG*2+1)], xG);
            end
        end
    end

fitfcn = @(op, x) nmgauss(x, op);

out = lsqcurvefit(fitfcn, Guess, x, p, lb, ub);

figure('Name',sprintf('%dx%d Gaussians', n,m))
bar(x, p, 'FaceColor', [.7 .7 .7], 'EdgeColor', [.8 .8 .8])
hold on
str = [];
%Create a string displaying amplitude, mean, sd of each gaussian
for i = 1:n
    stra = sprintf('Mean: %0.2f\n', out(i,1));
    str = [str stra];%#ok<AGROW>
    for j = 1:m
        plot(x, gauss([out(i,j*2), out(i,1)*relmean(j), out(i,j*2+1)],x))
        strb = sprintf(' Relmean: %0.2f, Mean: %0.2f, Amp: %0.3f, SD: %0.1f\n', relmean(j), relmean(j)*out(i,1), out(i,j*2:j*2+1));
        str = [str strb]; %#ok<AGROW>
    end
end
y = fitfcn(out, x);

%Place the text at (where curve hits half maxY, .9*maxY)
[texty, ind] = max(y);
textxind = find(x > x(ind) & y < texty/2,1,'first');
plot(x, y, 'Color','k')

text(x(textxind), texty*.9, str)
end