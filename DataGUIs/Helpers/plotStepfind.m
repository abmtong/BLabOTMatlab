function plotStepfind( da, in, me, tr )
%Plots a pretty stepfinding result

figure name PlotStepfind

plot(da,'Color',.7*ones(1,3))
hold on
plot(tr,'Color','g')
dt = 5;
dc = 10;
for j = 1:length(me)-1
    line((in(j+1))*[1 1] - [0 dt], me(j+1) * [1 1] - [0 dc], 'Color', [0.5 0 0])
    text(double((in(j+1))-dt), double(me(j+1))-dc, sprintf('%0.1f',me(j)-me(j+1)));
end

end

