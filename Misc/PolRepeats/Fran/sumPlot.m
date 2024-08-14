function out = sumPlot(inax, xl)

%Integrate xl1:xl2

chs = inax.Children;
len = length(chs);
out = cell(1,len);
for i = 1:len
    ch = chs(i);
    
    %Only do on lines
    if ~isa(ch, 'matlab.graphics.chart.primitive.Line')
        continue
    end
    
    %Get DisplayName field
    if isprop(ch, 'DisplayName')
        nam = ch.DisplayName;
    else
        nam = '';
    end
    
    %Integrate. Assume dx is constant.
    dx = median(diff(ch.XData));
    
    ycrop = ch.YData( ch.XData >= xl(1) & ch.XData < xl(2) );
    
    out{i} = struct('nam', nam, 'sum', sum(ycrop) * dx, 'xl', xl);
end

%Concatenate
out = [out{:}];

%Reverse
out = out(end:-1:1);







