function plottt(varargin)
%Plots multiple graphs to the current axis (one-argument @plot), first is gray
%Can also be used as a quick way to plot one thing as gray
%e.g. plott(line1, line2, line3) instead of hold on, plot(line1), plot(line2), plot(line3), hold off

hold on
plot(varargin{1}, 'Color', [.8,.8,.8]);
for i = 2:length(varargin)
    plot(varargin{i})
end