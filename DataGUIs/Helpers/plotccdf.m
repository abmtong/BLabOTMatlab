function out = plotccdf(data)

n = length(data);
o = plot( sort(data) ,(n:-1:1)/n);

if nargout > 0
    out = o;
end