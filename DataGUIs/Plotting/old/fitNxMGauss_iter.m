function fitNxMGauss_iter(guessmean, relmean, xl, sdrange)
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
if nargin < 4 || isempty(sdrange)
    sdrange = [-2 2];
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

%check if from @bar (is patch)
if isa(ax.Children(end), 'patch')
[x, ix] = unique(x);
p = p(ix);
end
%renormalize
p = p / sum(p) * mean(diff(x));

guessmean = guessmean(1);

%Relmean should fit the leftmost peak first, call this relative height 1
relmean = sort(relmean);
relmean = relmean/relmean(1);

n = length(relmean);

%Fit first gaussian with fitgauss_iter
[fit1, gauss] = fitgauss_iter(x, p, sdrange);
% @(x0,x)gauss = normpdf(x,x0(1),x0(2)) * x0(3)
%Next gaussians have means that are multiples of relmean
xsda = fit1(2) * (2:n); % guess sd increases linearly
xga = fit1(3) * .5.^(1:n-1); %guess amp is 0.5 ^ n
%Reshape to the order we want
xg = [xsda; xga];
xg = xg(:)';

    function outY = nmgauss(xx0, xx)
        outY = zeros(1,length(xx));
        nG = length(relmean);
        outY = outY + gauss(fit1,xx);
        for iG = 2:nG
            outY = outY + gauss([fit1(1)*relmean(iG) xx0(iG*2-3) xx0(iG*2-2)], xx);
        end
    end

out = lsqcurvefit(@nmgauss, xg, x, p);
m=1;
figure('Name',sprintf('%dx%d Gaussians', n,m))
bar(x, p, 'FaceColor', [.7 .7 .7], 'EdgeColor', [.8 .8 .8])
hold on
plot(x, nmgauss(out,x))
for i =1:n
    if i == 1
        plot(x,gauss(fit1, x))
    else
        plot(x,gauss([fit1(1)*relmean(i) out(i*2-3) out(i*2-2)], x))
    end
end
% str = [];
% %Create a string displaying amplitude, mean, sd of each gaussian
% for i = 1:n
%     stra = sprintf('Mean: %0.2f\n', out(i,1));
%     str = [str stra];%#ok<AGROW>
%     for j = 1:m
%         plot(x, gauss([out(i,j*2), out(i,1)*relmean(j), out(i,j*2+1)],x))
%         strb = sprintf(' Relmean: %0.2f, Mean: %0.2f, Amp: %0.3f, SD: %0.1f\n', relmean(j), relmean(j)*out(i,1), out(i,j*2:j*2+1));
%         str = [str strb]; %#ok<AGROW>
%     end
% end
% y = fitfcn(out, x);

% %Place the text at (where curve hits half maxY, .9*maxY)
% [texty, ind] = max(y);
% textxind = find(x > x(ind) & y < texty/2,1,'first');
% plot(x, y, 'Color','k')

% text(x(textxind), texty*.9, str)
end