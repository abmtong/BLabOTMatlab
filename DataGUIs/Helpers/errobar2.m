function out = errorbar2(xx, yy, ee, wid)
%Errorbar but with controllable errorbar widths
%To mark the datapt itself, do a separate plot over it

if nargin < 4 || isempty(wid)
    wid = median( diff( sort(xx) ))/3;
end

%Plot Errorbar: three line segments

len = length(xx);
out = cell(3, len);
for i = 1:length(xx)
    %Let's define the six points that make up the I shape
    
    %The |
    x1 = xx(i) * [1 1];
    y1 = yy + [-ee(i) ee(i)];
    
    %The upper -
    x2 = xx(i) + [-wid +wid];
    y2 = yy(i) + ee(i);
    
    %The lower -
    x3 = xx(i) + [-wid +wid];
    y3 = yy(i) - ee(i);
    
    out(1, i) = plot(x1, y1);
    out(2, i) = plot(x2, y2);
    out(3, i) = plot(x3, y3);
    
    



end