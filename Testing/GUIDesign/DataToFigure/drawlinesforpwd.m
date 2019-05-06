function [out, mult] = drawlinesforpwd(mult)

if nargin <1
% a=ginput(2);
% mult = mean([ a(1) a(2)/2]);
a=ginput(1);
mult = a(1);
end

out(1) = line( mult * [1 1], get(gca, 'YLim') );
out(2) = line( mult * [2 2], get(gca, 'YLim') );
out(3) = line( mult * [3 3], get(gca, 'YLim') );
