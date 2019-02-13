% y = in_zeros(x,n)
%
% Insert n zeros between elements of vector x
% and return in y. Used in discrete wavelet transform.
%
function y = in_zeros(x,n)
%n < 0 undoes positive n
if n < 0
    y = x(1:-n+1:end);
    return
end

%zero n does nothing
if n == 0
    y = x;
    return
end

%default behavior, pad with zeroes
y = zeros(1,(n+1)*length(x));
y(1:n+1:end) = x; % insert data into y