function ft = rob_unffrc(frcs)
%Fits unfolding forces to some fcn

kT = 4.14; %pN nm. Below, always used as dx/kT, so just affects dx
r=60; %Loading rate, pN/s. Below, always used as ku/r, so just affects ku

%Theoretical pdf, x0 = [rate, shape]
mlepdf = @(x,dx,ku)  ku/ r * exp( x * dx / kT) .* exp( -ku * kT / r / dx .* ( exp(x*dx/kT) -1 ) );

xg = [1 1e-1];
lb = [0 0];
ub = [inf inf];

oo = optimset(optimset('fminsearch'), 'MaxFunEvals', 1e4*length(xg), 'MaxIter', 1e4*length(xg));
ft = mle(frcs, 'pdf', mlepdf, 'start', xg, 'LowerBound', lb, 'UpperBound', ub, 'Options', oo);

%Plot data as histogram, ccdf
[p, x] = nhistc(frcs, .2);
figure
ax1=subplot(2,1,1); 
bar(ax1,x,p);
hold(ax1, 'on')

ftc = num2cell(ft);
plot(ax1, x, mlepdf(x, ftc{:}))


ax2=subplot(2,1,2); 
semilogy(ax2, sort(frcs), 1-(0:length(frcs)-1)/length(frcs));
hold(ax2, 'on')
cdf = cumsum(mlepdf(x, ftc{:})) * mean(diff(x));
plot(ax2, x, (cdf(end)-cdf) )
%Plot fit

% fprintf('Gamma with occupancy %0.2f%%, mean %0.2f, shape %0.2f; Exp with mean %0.2f\n', ft(1)*100, ft(3)/ft(2), ft(3), 1/ft(4))