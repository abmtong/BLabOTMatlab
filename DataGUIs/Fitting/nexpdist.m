function out = nexpdist(n)

%A sum of N exp's, for getDist
exppdf = @(x,a,k) a * k * exp(-x*k);
expcdf = @(x,a,k) a * exp(-x*k);

%Just do up to 5 pdfs. No great way to do this programatically?
switch n
    case 1
        out.pdf = @(x,a,k)exppdf(x, a, k) / a;
        out.cdf = @(x,a,k)expcdf(x, a, k) / a;
    case 2
        out.pdf = @(x,a1,k1,a2,k2) (exppdf(x, a1,k1) + exppdf(x, a2,k2)) / (a1+a2);
        out.cdf = @(x,a1,k1,a2,k2) (expcdf(x, a1,k1) + expcdf(x, a2,k2)) / (a1+a2);
    case 3
        out.pdf = @(x,a1,k1,a2,k2,a3,k3)(exppdf(x, a1,k1) + exppdf(x, a2,k2) + exppdf(x, a3,k3))/(a1+a2+a3);
        out.cdf = @(x,a1,k1,a2,k2,a3,k3)(expcdf(x, a1,k1) + expcdf(x, a2,k2) + expcdf(x, a3,k3))/(a1+a2+a3);
    case 4
        out.pdf = @(x,a1,k1,a2,k2,a3,k3,a4,k4)(exppdf(x, a1,k1) + exppdf(x, a2,k2) + exppdf(x, a3,k3) + exppdf(x, a4,k4))/(a1+a2+a3+a4);
        out.cdf = @(x,a1,k1,a2,k2,a3,k3,a4,k4)(expcdf(x, a1,k1) + expcdf(x, a2,k2) + expcdf(x, a3,k3) + expcdf(x, a4,k4))/(a1+a2+a3+a4);
    case 5
        out.pdf = @(x,a1,k1,a2,k2,a3,k3,a4,k4,a5,k5)(exppdf(x, a1,k1) + exppdf(x, a2,k2) + exppdf(x, a3,k3) + exppdf(x, a4,k4) + exppdf(x, a5,k5))/(a1+a2+a3+a4+a5);
        out.cdf = @(x,a1,k1,a2,k2,a3,k3,a4,k4,a5,k5)(expcdf(x, a1,k1) + expcdf(x, a2,k2) + expcdf(x, a3,k3) + expcdf(x, a4,k4) + expcdf(x, a5,k5))/(a1+a2+a3+a4+a5);
    otherwise
        error('%d is too many exps, need to add')
end
out.lb = repmat([0 0], 1, n);
out.ub = repmat([1 inf], 1, n);
out.cmt = sprintf('Sum of %d exponentials, height x0(odd) and rate x0(even)', n);