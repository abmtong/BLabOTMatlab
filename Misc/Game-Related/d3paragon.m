function outXP = d3paragon(n, cum)
%cum = cumulative or not
if nargin < 2
    cum = 0;
end

if nargin < 1
    n = 1e3;
end

if n < 750
    outXP = [];
    fprintf('Too low to calc');
elseif n<2250
    if cum
        outXP = 120000 * ( 197481729 + 34 * n * ( 15 * n - 18281 ) );
    else
        outXP = 8160000 * ( 15 * n - 9148 );
    end
else
    if cum
        outXP = 1000 * ( 17 * ( ( n + 1 )^3 - 3385291 * ( n + 1 ) + 5961719465 ) + 5 )  ;
    else
        outXP = 51000 * ( n * ( n + 1 ) - 1128430 )  ;
    end
end