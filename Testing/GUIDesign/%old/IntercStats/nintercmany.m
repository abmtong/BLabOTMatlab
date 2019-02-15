function [nintercsum, avginterc] = nintercmany(r, n)

nintercsum = zeros(n, 6);
figure Name NintercMany
hold on
avginterc=0;
for i = 1:n
    [st, nintercsum(i,:)] = modelneighexcl(r);
    avginterc = avginterc + sum(st)/length(st);
end
avginterc = avginterc / n;

nintercsum = sum(nintercsum,1);

plot(0:5, nintercsum/sum(nintercsum), 'LineWidth', 2, 'Color', 'k')