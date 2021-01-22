function out = nexpdist_cfit(n)

%A sum of N exp's, for getDist
exppdf = @(x,a,k) a * k * exp(-x*k);
expcdf = @(x,a,k) a * exp(-x*k); %Actually the ccdf
explcdf =@(x,a,k) log(a) -x*k; %Actually the ccdf 

function out = nexppdf(x0,x)
    out = zeros(size(x));
    for i = 1:n
        out = out + exppdf(x, x0( (i-1)*2+1 ), x0( (i-1)*2+2 ));
    end
end

function out = nexpcdf(x0,x)
    out = zeros(size(x));
    for i = 1:n
        out = out + expcdf(x, x0( (i-1)*2+1 ), x0( (i-1)*2+2 ));
    end
end

function out = nexplcdf(x0,x)
    out = zeros(size(x));
    for i = 1:n
        out = out + explcdf(x, x0( (i-1)*2+1 ), x0( (i-1)*2+2 ));
    end
end

out.pdf = @nexppdf;
out.ccdf = @nexpcdf;
out.lccdf = @nexplcdf;

% switch n
%     case 1
%         out.pdf = @(x0,x)exppdf(x, x0(1), x0(2));
%         out.cdf = @(x0,x)expcdf(x, x0(1), x0(2));
%     case 2
%         out.pdf = @(x0,x)(exppdf(x, x0(1), x0(2)) + exppdf(x, x0(3), x0(4)));
%         out.cdf = @(x0,x)(expcdf(x, x0(1), x0(2)) + expcdf(x, x0(3), x0(4)));
%     case 3
%         out.pdf = @(x0,x)(exppdf(x, x0(1), x0(2)) + exppdf(x, x0(3), x0(4)) + exppdf(x, x0(5), x0(6)));
%         out.cdf = @(x0,x)(expcdf(x, x0(1), x0(2)) + expcdf(x, x0(3), x0(4)) + expcdf(x, x0(5), x0(6)));
%     case 4
%         out.pdf = @(x0,x)(exppdf(x, x0(1), x0(2)) + exppdf(x, x0(3), x0(4)) + exppdf(x, x0(5), x0(6)) + exppdf(x, x0(7), x0(8)));
%         out.cdf = @(x0,x)(expcdf(x, x0(1), x0(2)) + expcdf(x, x0(3), x0(4)) + expcdf(x, x0(5), x0(6)) + expcdf(x, x0(7), x0(8)));
%     case 5
%         out.pdf = @(x0,x)(exppdf(x, x0(1), x0(2)) + exppdf(x, x0(3), x0(4)) + exppdf(x, x0(5), x0(6)) + exppdf(x, x0(7), x0(8)) + exppdf(x, x0(9), x0(10)));
%         out.cdf = @(x0,x)(expcdf(x, x0(1), x0(2)) + expcdf(x, x0(3), x0(4)) + expcdf(x, x0(5), x0(6)) + expcdf(x, x0(7), x0(8)) + expcdf(x, x0(9), x0(10)));
%     otherwise
%         error('%d is too many exps, need to add')
% end
out.lb = repmat([0 0], 1, n);
out.ub = repmat([1 inf], 1, n);
out.cmt = sprintf('Sum of %d exponentials, height x0(odd) and rate x0(even)', n);
end