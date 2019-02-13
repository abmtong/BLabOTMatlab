function fitdst(inY)
figure('Name', sprintf('fitdst %s', inputname(1)))
yp = inY(inY>0);
p = normHist(yp, 0.1);

dst = fitdist(yp', 'lognormal');

x = p(:,1);
y = p(:,2);
bar(x,y, 'FaceColor', [.7 .7 .7], 'EdgeColor', [.7 .7 .7])
hold on
plot(x,pdf(dst,x),'LineWidth',1)
xlim(x([1 end]))
text(0.1, 0.9*max(y), sprintf('mu: %0.2f\n sig: %0.2f', dst.mu, dst.sigma))
mode = exp(dst.mu - dst.sigma^2);
text(mode, pdf(dst, mode), sprintf('%0.2f',mode))