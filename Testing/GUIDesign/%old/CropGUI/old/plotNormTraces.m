function plotNormTraces(varargin)

figure('Name','Plot Normalized Traces')
hold on
for i = 1:length(varargin)
    plot(normalizeTrace(varargin{i}))
end
hold off