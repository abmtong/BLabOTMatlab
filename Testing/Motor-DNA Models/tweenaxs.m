function tweenaxs(ax1, ax2, ns, tp, res)
%Assuming the Children of ax1 and ax2 are compatible, tween between them
%Source is ax1, becomes coords in ax2

if nargin < 5
    res = 1;
end

if nargin < 3
    ns = 100; %100 steps
end

if nargin < 4
    tp = 0.1; %0.1s pause
end

ch1 = ax1.Children;
ch2 = ax2.Children;

for i = 1:ns
    %For every object in ax1 and ax2...
    for j = 1:length(ch1)
        %If it's a surface... 
        if isa(ch1(j), 'matlab.graphics.chart.primitive.Surface')
            r = i / ns;
            %Make the x/y coords a linear combination of them
            ch1(j).XData = (ch1(j).XData*(1-r) + ch2(j).XData*r);
            ch1(j).YData = (ch1(j).YData*(1-r) + ch2(j).YData*r);
            ch1(j).ZData = (ch1(j).ZData*(1-r) + ch2(j).ZData*r);
            ch1(j).CData = (ch1(j).CData*(1-r) + ch2(j).CData*r);
        end
    end
    pause(tp)
    drawnow
    addframe('outgif.gif', gcf, tp, res)
end
