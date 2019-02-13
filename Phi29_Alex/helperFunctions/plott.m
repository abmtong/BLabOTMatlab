function plott(varargin)
%Plots multiple graphs to the current axis (one-argument @plot)
%e.g. plott(line1, line2, line3) instead of hold on, plot(line1), plot(line2), plot(line3)

hold on
for i = 1:length(varargin)
    plot(varargin{i})
end