function out = phage_dwelldist(dws, method, verbose)
%Fits dws to some fcn

if nargin < 3
    verbose = 1;
end

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
    case 3
        % Gamma plus 1exp only after mean(x)? Nah...
        % Really, I need to fit [gam] and then [gam + exp]: can I write this out analytically?
        %I.e., I need the sum of a given gamma and then an arbitrary exp
        mlepdf = @(x, a1, k1, th, k2) a1 * gpdf( [k1 th] ,x) + (1-a1) * gpdf([k2 1.1], x);
        mlecdf = @(x, a1, k1, th, k2) a1 * gcdf( [k1 th] ,x) + (1-a1) * gcdf([k2 1.1], x);
        xg = [0.9 5/median(dws) 5 1/prctile(dws,95)];
        lb = [0 0 0 0];
        ub = [1 inf inf inf];
    case 4
        %Sum of any two gammas is given by this: (https://stats.stackexchange.com/questions/252191/how-do-gamma-distributions-add-and-what-would-that-model/252192#252192)
        %pdf(a1 b1 a2 b2 x) = b1^a1 * b2 ^ a2 / gamma(a1+a2) * exp(-b1 x)  x^(a1+a2-1) * {1F1(a2, a1+a2, (b1-b2)x)}
        % Where 1F1 is a 'confluent hypergeometric fcn of the 1o kind' writable as an infinite sum (we'll just truncate after N terms)
        %  https://mathworld.wolfram.com/ConfluentHypergeometricFunctionoftheFirstKind.html
        % I want the special case where a2 = 1 (i.e. a gamma and an exponential, but it doesn't seem to make this easier)
        
        
        %Alternatively, can be computed as a sum:
        % From 'The Dist of the Sum of Ind Gam Rnd Var' Moschopoulos 1984
        % Probably take this route...
end

oo = optimset(optimset('fminsearch'), 'MaxFunEvals', 1e4*length(xg), 'MaxIter', 1e4*length(xg));
[ft, ci] = mle(dws, 'pdf', mlepdf, 'start', xg, 'LowerBound', lb, 'UpperBound', ub, 'Options', oo);

if verbose
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
        case 3
            plot(ax1, x, gpdf(ft([2 3]),x)*ft(1))
            plot(ax1, x, gpdf([ft(4) 2],x)*(1-ft(1)))
            fprintf('Gamma with occupancy %0.2f%%, mean %0.2f, shape %0.2f; Gamma with mean %0.2f (set shape 2)\n', ft(1)*100, ft(3)/ft(2), ft(3), 1/ft(4))
            plot(ax2, x, gcdf(ft([2 3]),x)*ft(1));
            plot(ax2, x, gcdf([ft(4) 2],x)*(1-ft(1)))
    end
end

out.ft = ft;
out.ci = ci;
switch method
    case 1
        out.fh = @(x0,x) mlepdf(x, x0(1), x0(2), x0(3), x0(4) );
    case 2
        out.fh = @(x0,x) mlepdf(x, x0(1), x0(2) );
    case 3
        out.fh = @(x0,x) mlepdf(x, x0(1), x0(2), x0(3), x0(4) );
end
