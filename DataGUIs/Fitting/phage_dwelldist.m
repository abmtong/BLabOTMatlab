function ft = phage_dwelldist(dws, method)
%Fits dws to some fcn

if nargin < 2
    method = 1;
end

if iscell(dws)
    dws = [dws{:}];
end

% dws = dws(dws>.05);

%Gamma pdf, x0 = [rate, shape]
gpdf = @(x0,x) x0(1)^x0(2) ./ gamma(x0(2)) .* x.^(x0(2)-1) .* exp(-x*x0(1));
%Exp pdf
epdf = @(x0,x) x0 * exp(-x0*x);

%Ccdfs, for later
gcdf = @(x0,x) 1- gammainc(x0(1)*x, x0(2));
ecdf = @(x0,x) exp(-x0 * x);


switch method
    case 1 %Gamma plus 1exp
        %Combined pdf for @mle
        mlepdf = @(x, a1, k1, th, k2) a1 * gpdf( [k1 th] ,x) + (1-a1) * epdf(k2, x);
        mlecdf = @(x, a1, k1, th, k2) a1 * gcdf( [k1 th] ,x) + (1-a1) * ecdf(k2, x);
        % fitfcn = @(x0,x) gccdf(x0([1 2]),x) + eccdf(x0(3),x);
        % fitmle = @(x0) sum( log( fitfcn(x0,dws) ) );
        xg = [0.9 5/median(dws) 5 1/prctile(dws,95)];
        lb = [0 0 0 0];
        ub = [1 inf inf inf];
    case 2 %Gamma only
        mlepdf = @(x, k1, th)  gpdf( [k1 th] ,x) ;
        mlecdf = @(x, k1, th)  gcdf( [k1 th] ,x) ;
        % fitfcn = @(x0,x) gccdf(x0([1 2]),x) + eccdf(x0(3),x);
        % fitmle = @(x0) sum( log( fitfcn(x0,dws) ) );
        xg = [5/median(dws) 5 ];
        lb = [ 0 0];
        ub = [ inf inf ];
end

oo = optimset(optimset('fminsearch'), 'MaxFunEvals', 1e4*length(xg), 'MaxIter', 1e4*length(xg));
ft = mle(dws, 'pdf', mlepdf, 'start', xg, 'LowerBound', lb, 'UpperBound', ub, 'Options', oo);

%Plot data as histogram, ccdf
[p, x] = nhistc(dws, .01);
figure
ax1=subplot(2,1,1); 
bar(ax1,x,p);
hold(ax1, 'on')

ax2=subplot(2,1,2); 
semilogy(ax2, sort(dws), 1-(0:length(dws)-1)/length(dws));
hold(ax2, 'on')
%Plot fit
ftc = num2cell(ft);
plot(ax1, x, mlepdf(x,ftc{:}));
cdf = mlecdf(x, ftc{:});
plot(ax2, x, cdf )
%Per-method plotting/printing
switch method
    case 1
        plot(ax1, x, gpdf(ft([2 3]),x)*ft(1))
        plot(ax1, x, epdf(ft(4),x)*(1-ft(1)))
        fprintf('Gamma with occupancy %0.2f%%, mean %0.2f, shape %0.2f; Exp with mean %0.2f\n', ft(1)*100, ft(3)/ft(2), ft(3), 1/ft(4))
        plot(ax2, x, gcdf(ft([2 3]),x)*ft(1));
        plot(ax2, x, ecdf(ft(4),x)*(1-ft(1)))
    case 2
        fprintf('Gamma with mean %0.2f, shape %0.2f\n', ft)
end
