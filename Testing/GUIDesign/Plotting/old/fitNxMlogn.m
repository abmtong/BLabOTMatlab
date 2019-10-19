function fitNxMlogn(guessmean, relmean, onlypos)
%Fits lognormals with mean guessmean x relmeans

%length(guessmean) is the number of gaussians to fit
if ~nargin || isempty(guessmean)
    guessmean = 10;
end
if nargin<2  || isempty(relmean)
    relmean = 1;
end
if nargin < 3 || isempty(onlypos)
    onlypos = 1;
end

ax = gca;
x = ax.Children(end).XData;
p = ax.Children(end).YData;
if onlypos
    keepind = x>0;
    x = x(keepind);
    p = p(keepind);
end

%Convert guesses to log space
guessmean = log(guessmean);

%Make row vectors
x = double(x(:)');
p = double(p(:)');
guessmean = guessmean(:)';

lognpdf = @(op, x) op(1) * exp(-(log(x)-op(2)).^2/2/op(3)) ./x;

n= length(guessmean);
m = length(relmean);

%       [mean1 amp1a sd1a amp1b sd1b ...; ''; '';]
%       Guess [.1, mean, 1, .1, 1]
%Guess each is a gaussian with height .1, mean given, sd 1
Guess = [guessmean' repmat([.1 1],n,m)];
lb = [zeros(n,1) repmat([0 0],n,m)];
ub = [20*ones(n,1) repmat([1 20],n,m)];

    function outY = nmgauss(xG, opG)
        [nG, mG] = size(opG);
        mG = (mG-1)/2;
        outY = zeros(1,length(xG));
        for iG = 1:nG
            for jG = 1:mG
                outY = outY + lognpdf([opG(iG,jG*2), opG(iG,1)*relmean(jG), opG(iG,jG*2+1)], xG);
            end
        end
    end

fitfcn = @(op, x) nmgauss(x, op);

out = lsqcurvefit(fitfcn, Guess, x, p, lb, ub);

figure('Name',sprintf('%dx%d Lognormals', n,m))
bar(x, p, 'FaceColor', [.7 .7 .7], 'EdgeColor', [.8 .8 .8])
hold on
str = [];
%Create a string displaying amplitude, mean, sd of each gaussian
for i = 1:n
    stra = sprintf('Mode: %0.2f\n', exp(out(i,1)));
    str = [str stra];%#ok<AGROW>
    for j = 1:m
        plot(x, lognpdf([out(i,j*2), out(i,1)*relmean(j), out(i,j*2+1)],x))
        strb = sprintf(' Relmean: %0.2f, Mode: %0.2f, Amp: %0.2f, Var: %0.1f\n', relmean(j), exp(relmean(j)*out(i,1)), out(i,j*2:j*2+1));
        str = [str strb]; %#ok<AGROW>
    end
end
y = fitfcn(out, x);

%Place the text at (where curve hits half maxY, maxY)
[texty, ind] = max(y);
textxind = find(x > x(ind) & y < texty/2,1,'first');
plot(x, y, 'Color','k')

text(x(textxind), texty, str)
end