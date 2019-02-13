function [tf, outy, rejy] = isoutlier(iny)

med = median(iny);
mad = median( abs(iny - med) );
madscale = 1.4826; %for normal data, mad to sd conversion
ub = med + 3*mad*madscale;
lb = med - 3*mad*madscale;

tf = iny > ub | iny < lb;

if nargout >1
    outy = iny(~tf);
end
if nargout >2
    rejy = iny(tf);
end