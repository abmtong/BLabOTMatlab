function fitNxMGaussMoff(guessmean, relmean, onlypos)
%Fits gaussians with mean guessmean x relmeans
%SDs are the same, heights are geometrically decreasing

%length(guessmean) is the number of gaussians to fit
if ~nargin || isempty(guessmean)
    guessmean = 2.5;
end
if nargin<2  || isempty(relmean)
    relmean = 1:4;
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

%Make row vectors
x = double(x(:)');
p = double(p(:)');

%gauss = @([amp mean sd], x)
gauss = @(op, x) op(1) * exp(-(x-op(2)).^2/2/op(3));

n= length(guessmean);
m = length(relmean);

%Guess gaussian amp .1, mean guessmean, sd 1, geometric factor 0.1
Guess = [guessmean .1 1 .1];
lb = [0 0 0 0];
ub = [20 1 20 1];

    function outY = moffgauss(xG, opG)
        outY = zeros(1,length(xG));
        for iG = 1:m
            outY = outY + gauss([opG(2) * opG(4)^(iG-1), opG(1)*relmean(iG), opG(3)], xG);
        end
    end

fitfcn = @(op, x) moffgauss(x, op);

out = lsqcurvefit(fitfcn, Guess, x, p, lb, ub);

figure('Name',sprintf('%dx%d Gaussians Moffit', n,m))
bar(x, p, 'FaceColor', [.7 .7 .7], 'EdgeColor', [.8 .8 .8])
hold on
str = [];
%Create a string displaying amplitude, mean, sd of each gaussian
    stra = sprintf('Mean: %0.2f, SD: %0.2f, Geo: %0.2f \n', out(1), out(3), out(4) );
    str = [str stra];
    for j = 1:m
        plot(x, gauss([out(2)*out(4)^(j-1), out(1)*relmean(j), out(3)],x))
        strb = sprintf(' Relmean: %0.2f, Mean: %0.2f, Amp: %0.2f\n', relmean(j), relmean(j)*out(1), out(2) * out(4)^(j-1));
        str = [str strb]; %#ok<AGROW>
    end
y = fitfcn(out, x);

%Place the text at (where curve hits half maxY, maxY)
[texty, ind] = max(y);
textxind = find(x > x(ind) & y < texty/2,1,'first');
plot(x, y, 'Color','k')

text(x(textxind), texty, str)
end