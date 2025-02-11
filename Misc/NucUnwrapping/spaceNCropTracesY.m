function spaceNCropTracesY(inax, amt)

xthr = 7;

if nargin < 1 || isempty(inax)
    inax = gca;
end

if nargin < 2
    amt = 60;
end
    
chs = inax.Children;
len = length(chs);
ii = 0;
for i = 1:len
    ch = chs(i);
    
    %Check that this is a Plot
    if ~isa(ch, 'matlab.graphics.chart.primitive.Line')
        continue
    end
    
    %Get Y-value of x>fthr
    
    ind = find(ch.XData > xthr, 1, 'first');
    if isempty(ind) %More robust fallback
        ind = find(ch.XData < xthr, 1, 'last');
    end
    val = ch.YData(ind);
    
%     set(ch, 'XData', ch.XData(1:maxi), 'YData', ch.YData(1:maxi))
    
    ch.YData = ch.YData -val + ii * amt;
    ii = ii + 1;
    
end