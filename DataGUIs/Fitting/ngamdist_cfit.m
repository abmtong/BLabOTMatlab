function out = ngamdist_cfit(n, shape)

%A sum of N exp's, for getDist
gampdf = @(x,a,k) a * k^shape / gamma(shape) * x .^ (shape-1) * exp(-x*k); 
gamcdf = @(x,a,k) a * gammainc(k*x, shape); 

function out = ngampdf(x0,x)
    out = zeros(size(x));
    for i = 1:n
        out = out + gampdf(x, x0( (i-1)*2+1 ), x0( (i-1)*2+2 ));
    end
end

function out = ngamccdf(x0,x)
    out = zeros(size(x));
    for i = 1:n
        out = out + gamcdf(x, x0( (i-1)*2+1 ), x0( (i-1)*2+2 ));
    end
    out = sum(x0(1:2:end)) - out; %Change to ccdf
end

out.pdf = @ngampdf;
out.ccdf = @ngamccdf;

out.lb = repmat([0 0], 1, n);
out.ub = repmat([1 inf], 1, n);
out.cmt = sprintf('Sum of %d gammas with shape %d, height x0(odd) and rate x0(even)', n, shape);
end