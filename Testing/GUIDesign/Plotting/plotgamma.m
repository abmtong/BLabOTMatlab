function plotgamma(data, binsz, cutoff)

if nargin < 2
    binsz = 0.01;
end
if nargin < 3
    cutoff = max(data);
end

%make cutoff a integer multiple of binsz
cutoff = ceil(cutoff/binsz) * binsz;

datac = data(data < cutoff);
n = length(datac);

gd = fitdist(datac(:), 'gamma');

nmin = mean(datac)^2 / var(datac);

bins = binsz:binsz:cutoff;
hy = histc(datac, bins);

cutmax = ceil(max(data)/binsz) * binsz;
binall = binsz:binsz:cutmax;
hya = histc(data, binall);

figure('Name', sprintf('%s with binsz %0.3f and cutoff %0.3f', inputname(1), binsz, cutoff))

hold on

hscale = binsz*n;

[gd2,gy2] = fitgamma(binall - binsz/2,hya/hscale);

bar(binall-binsz/2, hya/hscale, 'FaceColor', [.7 .7 .7])

bar(bins-binsz/2, hy/hscale)

gy = pdf(gd, bins);
plot(bins-binsz/2, gy, 'LineWidth', 2);
plot(binall-binsz/2, gy2, 'LineWidth', 2);

herr = sqrt(hy.*(1-hy/n));
errorbar(bins-binsz/2, hy/hscale, herr/hscale, '.')
xlim([0 cutoff*1.5])
fprintf('gamma: %0.2f, gamma2: %0.2f, nmin: %0.2f\n', gd.a, gd2(1), nmin);
