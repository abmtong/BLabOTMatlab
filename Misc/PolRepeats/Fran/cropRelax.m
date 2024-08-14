function out = cropRelax(inax)

%Crop for real, so first 'local minimum' of height

dy = 10; %Crop after Y falls by this much, then crop to max

ch = inax.Children;


for i = 1:length(ch)
    ob = ch(i);
    if ~isa(ob, 'matlab.graphics.chart.primitive.Line')
        continue
    end
    
    yd = ob.YData;
    hei = length(yd);
    
    %Find first time Y falls from previous local max by dy
    ymx = arrayfun(@(x) max( yd(1:x) ), 1:hei );
    ki = find( ymx - yd > dy, 1, 'first' );
    if isempty(ki)
        continue
    end
    
    %And crop to maximum value in this range
    [~, imax] = max( yd(1:ki) );
    
    set(ob, 'XData', ob.XData(1:imax), 'YData', ob.YData(1:imax))
end