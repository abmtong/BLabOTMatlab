function spaceNCropTraces(inax, amt)


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
    
    %Get index of max
    [~, maxi] = max(ch.YData);
    
    set(ch, 'XData', ch.XData(1:maxi), 'YData', ch.YData(1:maxi))
    
    ch.XData = ch.XData + ii * amt;
    ii = ii + 1;
    
end