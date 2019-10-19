function x = rescale(x, mn, mx)
%Rescales x to have min mn, max mx
%Accepts mn = [mn mx], too

if nargin < 3
    mx = mn(2);
    mn = mn(1);
end

%Scale to [0,1], then [0,mx-mn], then [mn,mx]
x = ( x - min(x) ) / range(x) * (mx-mn) + mn;